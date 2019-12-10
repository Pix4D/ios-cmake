# fail if any commands fails
set -e

LATEST_IOS_SIMULATOR_RUNTIME_ID=$(xcrun simctl list runtimes -j | python -c "from distutils.version import StrictVersion; import json,sys; obj=json.load(sys.stdin); runtimes = obj['runtimes']; iOSRuntimes = [item['identifier'] for item in runtimes if 'iOS' in item['identifier']]; print(sorted(iOSRuntimes, key=lambda item: StrictVersion('.'.join(item.split('-')[-2:])))[-1]); ")
LATEST_IOS_SIMULATOR_DEVICE_TYPE_ID=$(xcrun simctl list devicetypes | grep iPhone | tail -1 | awk '{print $NF}' | tr -d '()')
SIMULATOR_INSTANCE_NAME="Test iPhone - $LATEST_IOS_SIMULATOR_DEVICE_TYPE_ID - $LATEST_IOS_SIMULATOR_RUNTIME_ID"
SIMULATOR_DESTINATION_UUID=$(xcrun simctl create "$SIMULATOR_INSTANCE_NAME" $LATEST_IOS_SIMULATOR_DEVICE_TYPE_ID $LATEST_IOS_SIMULATOR_RUNTIME_ID)

#On exit : cleanup the new, clean iOS Simulator instance for running the automated tests
function cleanup_simulator_instance {
    echo "cleanup_simulator_instance"
    set +e #we must continue execution even if "xcrun simctl shutdown ..." fails
    xcrun simctl shutdown $SIMULATOR_DESTINATION_UUID
    xcrun simctl delete $SIMULATOR_DESTINATION_UUID
    killall "Simulator"
    set -e #re-enable : stop execution on any non-zero return values
}
trap cleanup_simulator_instance EXIT
