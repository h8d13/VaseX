# Maintainer: Hadean <hadean-eon-dev@proton.me>
pkgname=vasex-git
pkgver=0016
pkgrel=1
pkgdesc="VaseOS - Artix Linux testing suite and installation platform"
arch=('x86_64')
url="https://github.com/h8d13/VaseX"
license=('GPL')
depends=('base' 'git' 'gnupg' 'jq' 'python' 'curl' 'wget' 'tree')
makedepends=('archiso' 'squashfs-tools' 'arch-install-scripts')
source=("${pkgname}::git+https://github.com/h8d13/Vase.git")
sha256sums=('SKIP')

prepare() {
    cd "$pkgname"
    git submodule update --init --recursive
}

package() {
    cd "$pkgname"

    # Install to /opt/vasex using git archive (preserves permissions)
    install -dm755 "$pkgdir/opt/vasex"
    git archive HEAD | tar -x -C "$pkgdir/opt/vasex"

    # Copy submodules
    export pkgdir="$pkgdir"
    git submodule foreach --recursive 'mkdir -p "$pkgdir/opt/vasex/$path" && git archive HEAD | tar -x -C "$pkgdir/opt/vasex/$path"'

    # Include .git for update functionality
    cp -a .git "$pkgdir/opt/vasex/"

    # Copy submodule .git directories
    find . -path '*/.git' -type d | while read gitdir; do
        subpath="${gitdir#./}"
        mkdir -p "$pkgdir/opt/vasex/$(dirname "$subpath")"
        cp -a "$gitdir" "$pkgdir/opt/vasex/$(dirname "$subpath")/"
    done

    # Create wrapper script
    install -dm755 "$pkgdir/usr/bin"
    cat > "$pkgdir/usr/bin/vasex" <<'EOF'
#!/bin/bash
cd /opt/vase && exec sudo ./main "$@"
EOF
    chmod +x "$pkgdir/usr/bin/vasex"

    # License
    install -Dm644 "$pkgdir/opt/vasex/LICENSE" "$pkgdir/usr/share/licenses/vase/LICENSE"

    # Man page
    install -Dm644 "$pkgdir/opt/vasex/.github/man/vasex.1" "$pkgdir/usr/share/man/man1/vasex.1"
}
