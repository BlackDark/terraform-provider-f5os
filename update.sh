#!/bin/bash

set -e

# Define variables
VERSION=$(git describe --tags --abbrev=0)
BASE_URL="https://github.com/F5Networks/terraform-provider-f5os/archive/refs/tags"
TARBALL="${VERSION}.tar.gz"
EXTRACT_DIR="upstream"

echo "Checking out release version: $VERSION"

# Download the tarball if not already downloaded
if [ ! -f "$TARBALL" ]; then
    echo "Downloading release $VERSION..."
    curl -L -o "$TARBALL" "$BASE_URL/$TARBALL"
else
    echo "$TARBALL already exists, skipping download."
fi

# Extract the tarball into the upstream directory
echo "Extracting $TARBALL to $EXTRACT_DIR/ ..."
mkdir -p "$EXTRACT_DIR"
tar -xzf "$TARBALL" -C "$EXTRACT_DIR" --strip-components=1

# remove all current files and replace with new ones
(git rm -r .) || true
(
    cd ${EXTRACT_DIR}
    rsync -a --remove-source-files ./ ../
)

# # Replace directories and perform text substitutions
# echo "Replacing vendor directory with upstream contents..."
# rm -rf vendor
# mv "$EXTRACT_DIR/vendor" .
# rm -rf f5osclient
# rm -rf f5os
mv vendor/gitswarm.f5net.com/terraform-providers/f5osclient .
#mv "${EXTRACT_DIR}/internal/provider" f5os
mv "internal/provider" f5os

# # Remove and restore docs and examples
# rm -rf docs examples
# mv "$EXTRACT_DIR/examples" .
# mv "$EXTRACT_DIR/docs" .

# Replace package names in source files
find f5os -type f -exec sed -i '' 's/package provider/package f5os/g' {} +
find f5osclient -type f -exec sed -i '' 's/package f5os/package f5osclient/g' {} +

find . -type f -name 'go.mod' -exec sed -i '' 's|gitswarm.f5net.com/terraform-providers/terraform-provider-f5os|github.com/BlackDark/terraform-provider-f5os|g' {} +
sed -i '' '/gitswarm\.f5net\.com\/terraform-providers\/f5osclient/d' go.mod
sed -i '' 's|"gitswarm.f5net.com/terraform-providers/terraform-provider-f5os/internal/provider"|provider "github.com/BlackDark/terraform-provider-f5os/f5os"|g' main.go


# Remove 3 lines starting from "# gitswarm" in vendor/modules.txt
sed -i '' '/^# gitswarm/{N;N;d;}' vendor/modules.txt

# Write a new go.mod file for f5osclient
# cat <<EOF > f5osclient/go.mod
# module github.com/BlackDark/terraform-provider-f5os
# go 1.23.0
# EOF

find f5os -type f -exec sed -i '' 's/"gitswarm\.f5net\.com\/terraform-providers\/f5osclient"/"github.com\/BlackDark\/terraform-provider-f5os\/f5osclient"/g' {} +

#echo "replace gitswarm.f5net.com/terraform-providers/f5osclient => ./f5osclient" >> go.mod

gofmt -w f5osclient
gofmt -w f5os

go mod tidy

# Clean up downloaded tarball and extracted files
echo "Cleaning up..."
rm -rf "$TARBALL" "$EXTRACT_DIR"
rm -rf upstream
rm -rf internal
rm -rf vendor/gitswarm.f5net.com

git add .

echo "All steps completed. Check the changes commit and retag with ${VERSION}."


