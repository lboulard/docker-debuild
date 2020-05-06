#!/usr/bin/python3

import sys
from pathlib import Path
from glob import glob
from io import StringIO
from .ninja_syntax import Writer

ROOT = Path(__file__).parent.parent

DOCKERUSER = "lboulard"


def dockerfiles(root=ROOT):
    files = glob("*/Dockerfile")
    files = [Path(x) for x in files]
    return files


def imagename(source):
    f = source.split("-")
    return DOCKERUSER + "/" + "-".join(f[:-2]) + "-" + f[-1] + ":" + f[-2]


def sort_source(s):
    f = [x.lower() for x in s.split("-")]
    order = {"dev": "a", "debuild": "b"}.get(f[-1], "z")
    return order + ":" + "-".join(f[:-1])


def uniq(seq):
    seen = set()
    add = seen.add
    return [x for x in seq if not (x in seen or add(x))]


def main():
    defaults, manuals, disabled = [], [], []
    for dockerfile in dockerfiles():
        p = dockerfile.parent
        if (p / ".disabled").exists():
            disabled.append(str(p))
        elif (p / ".manual").exists():
            manuals.append(str(p))
        else:
            defaults.append(str(p))
    if disabled:
        print("# Disabled build:\n#  - " + "\n#  - ".join(disabled))
    defaults = sorted(defaults, key=sort_source)
    manuals = sorted(manuals, key=sort_source)
    sources = defaults + manuals
    images = [imagename(x) for x in sources]

    #
    out = StringIO()
    w = Writer(out, width=120)
    w.comment("Generated using python3 -m mk")

    # Rules
    w.newline()
    w.rule(
        "docker-build",
        "docker build -t $image $source && touch $out",
        description="DOCKER $image",
        pool="console",
    )
    w.newline()
    w.rule(
        "docker-push", "docker push $image", description="PUSH $image", pool="console"
    )
    w.newline()
    w.rule(
        "docker-rmi",
        "docker rmi -f $images",
        description="RMI $images",
        pool="console",
    )

    # Image builds
    w.newline()
    w.comment("All images to build")
    for source, image in zip(sources, images):
        filetarget = source + "/.build"
        w.build(source, "phony", filetarget)
        deps = [source + "/Dockerfile"]
        implicit = None
        if source.endswith("-debuild"):
            implicit = "-".join(source.split("-")[:-1]) + "-dev"
        w.build(
            filetarget,
            "docker-build",
            deps,
            implicit=implicit,
            variables={"image": image, "source": source},
        )
    # Image push
    w.newline()
    w.comment("Docker pushes")
    for source, image in zip(sources, images):
        implicit = None
        if source.endswith("-debuild"):
            implicit = "-".join(source.split("-")[:-1]) + "-dev-push"
        w.build(
            source + "-push",
            "docker-push",
            variables={"image": image},
            implicit=implicit,
        )

    release_name = lambda s: "-".join(s.split("-")[:-1])
    distribution_name = lambda s: s.split("-")[0]

    # Phony
    ## Coalesce by releases/distributions
    releases = uniq(release_name(x) for x in sources)
    distributions = uniq(distribution_name(x) for x in sources)
    ## Images per release/distributions
    w.newline()
    w.comment("Docker build per releases")
    for release in releases:
        w.build(release, "phony", [src for src in sources if src.find(release) >= 0])
    w.newline()
    w.comment("Docker build per distributions")
    for distro in distributions:
        w.build(distro, "phony", [src for src in sources if src.startswith(distro)])
    ## All images
    w.newline()
    w.comment("Build all images")
    w.build("images", "phony", uniq(release_name(x) for x in defaults))
    ## Pushes per releases/distributions
    w.newline()
    w.comment("Docker push per release")
    for release in releases:
        w.build(
            release + "-push",
            "phony",
            [src + "-push" for src in sources if src.find(release) >= 0],
        )
    w.newline()
    w.comment("Docker push per distributions")
    for distro in distributions:
        w.build(
            distro + "-push",
            "phony",
            [src + "-push" for src in sources if src.startswith(distro)],
        )
    ## Push all default images
    w.newline()
    w.comment("Push all default images")
    w.build(
        "push",
        "phony",
        [release + "-push" for release in uniq(release_name(x) for x in defaults)],
    )
    ## Clobber
    w.newline()
    for release in releases:
        name, tagname = release.split("-", 1)
        w.build(
            "clobber-" + release,
            "docker-rmi",
            variables={
                "images": [
                    img
                    for img in images
                    if img.find(name) >= 0 and img.endswith(tagname)
                ]
            },
        )
    w.newline()
    w.comment("Destroy all images")
    w.build("clobber", "phony", ["clobber-" + release for release in releases])

    # Default target
    w.newline()
    w.default("images")

    # Write build.ninja
    print("Writing build.ninja")
    with open("build.ninja", "w+") as o:
        o.write(out.getvalue())


if __name__ == "__main__":
    main()
