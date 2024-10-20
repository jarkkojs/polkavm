#!/bin/bash

set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

source ../ci/jobs/detect-or-install-riscv-toolchain.sh

function build_example () {
    output_path="output/$1.polkavm"

    echo "> Building: '$1' (-> $output_path)"

    local target="riscv32emac-unknown-none-polkavm"
    local extra_flags="-C target-feature=+c -C relocation-model=pie -C link-arg=--emit-relocs -C link-arg=--unique --remap-path-prefix=$(pwd)= --remap-path-prefix=$HOME=~"

    RUSTFLAGS="$extra_flags" cargo build  \
        -Z build-std=core,alloc \
        --target "$PWD/$target.json" \
        -q --release --bin $1 -p $1

    pushd ..

    cargo run -q -p polkatool link \
        --run-only-if-newer -s guest-programs/target/$target/release/$1 \
        -o guest-programs/$output_path

    popd
}

build_example "example-hello-world"
