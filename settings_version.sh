#!/bin/sh

#@AUTHOR Boris Bielik
#@VERSION v1.0

function printHelp {
    echo "-p		     specify name of the plist"
    echo "-h, -help      show brief help"
	exit 0
}

PLIST_PATH=""

while test $# -gt 0; do
    case "$1" in
        -h|-help)
			printHelp
        ;;
            
        #plist path
        -p)
            if [ -z "$2" ]; then
            echo "No parameter was specified. Exiting..."
            exit 1;
            fi
            
            PLIST_PATH=$2
            shift 2
            ;;
        *)
        break;;
    esac
done

version=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${PLIST_PATH}")
#build=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${PLIST_PATH}")
version_build="$version (${CURRENT_PROJECT_VERSION})"
settings_bundle_path="$SRCROOT/Covid/Resources/Settings.bundle/Root.plist"

echo "Copying ${version_build} from ${PLIST_PATH} to ${settings_bundle_path}."
/usr/libexec/PlistBuddy -c "Set :PreferenceSpecifiers:1:DefaultValue $version_build" "${settings_bundle_path}"
