#!/bin/sh
set -e
set -u
set -o pipefail

function on_error {
  echo "$(realpath -mq "${0}"):$1: error: Unexpected failure"
}
trap 'on_error $LINENO' ERR

if [ -z ${UNLOCALIZED_RESOURCES_FOLDER_PATH+x} ]; then
  # If UNLOCALIZED_RESOURCES_FOLDER_PATH is not set, then there's nowhere for us to copy
  # resources to, so exit 0 (signalling the script phase was successful).
  exit 0
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

# This protects against multiple targets copying the same framework dependency at the same time. The solution
# was originally proposed here: https://lists.samba.org/archive/rsync/2008-February/020158.html
RSYNC_PROTECT_TMP_FILES=(--filter "P .*.??????")

case "${TARGETED_DEVICE_FAMILY:-}" in
  1,2)
    TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
    ;;
  1)
    TARGET_DEVICE_ARGS="--target-device iphone"
    ;;
  2)
    TARGET_DEVICE_ARGS="--target-device ipad"
    ;;
  3)
    TARGET_DEVICE_ARGS="--target-device tv"
    ;;
  4)
    TARGET_DEVICE_ARGS="--target-device watch"
    ;;
  *)
    TARGET_DEVICE_ARGS="--target-device mac"
    ;;
esac

install_resource()
{
  if [[ "$1" = /* ]] ; then
    RESOURCE_PATH="$1"
  else
    RESOURCE_PATH="${PODS_ROOT}/$1"
  fi
  if [[ ! -e "$RESOURCE_PATH" ]] ; then
    cat << EOM
error: Resource "$RESOURCE_PATH" not found. Run 'pod install' to update the copy resources script.
EOM
    exit 1
  fi
  case $RESOURCE_PATH in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}" || true
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.xib)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}" || true
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.framework)
      echo "mkdir -p ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" || true
      mkdir -p "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" $RESOURCE_PATH ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" || true
      rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH"`.mom\"" || true
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd\"" || true
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm\"" || true
      xcrun mapc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE="$RESOURCE_PATH"
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    *)
      echo "$RESOURCE_PATH" || true
      echo "$RESOURCE_PATH" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "${PODS_ROOT}/AMap3DMap/MAMapKit.framework/AMap.bundle"
  install_resource "${PODS_ROOT}/AlipaySDK-iOS/AlipaySDK.bundle"
  install_resource "${PODS_ROOT}/MJRefresh/MJRefresh/MJRefresh.bundle"
  install_resource "${PODS_CONFIGURATION_BUILD_DIR}/QIMCommon/QIMCommonResource.bundle"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/call_bg@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_audio_receive_normal@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_audio_receive_press@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_camera_white@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_invite_black@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_invite_blue@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_invite_gray@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_invite_white@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_loudspeaker_black@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_loudspeaker_blue@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_loudspeaker_gray@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_loudspeaker_white@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_mute_black@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_mute_blue@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_mute_gray@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_mute_white@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_reduce_black@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_reduce_blue@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_reduce_gray@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_reduce_white@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_video_black@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_video_blue@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_video_gray@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_video_white@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_av_audio_micro_normal@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_av_audio_micro_press@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_av_audio_receive_normal@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_av_audio_receive_press@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_av_reply_message_normal@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_av_reply_message_press@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_call_reject_normal@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_call_reject_press@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/im_skin_icon_audiocall_bg.jpg"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/portrait.jpg"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/portrait@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/voip_camera_icons_130x130_@1x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/voip_camera_icons_66x66_@3x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/voip_convert_icons_130x130_@1x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/voip_convert_icons_66x66_@3x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/sound/AVChat_busy.mp3"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/sound/AVChat_endCall.mp3"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/sound/AVChat_incoming.mp3"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/sound/AVChat_waitingForAnswer.mp3"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/sound/incomingRing.wav"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/sound/Message_system.mp3"
  install_resource "${PODS_CONFIGURATION_BUILD_DIR}/QIMKitVendor/QIMPinYin.bundle"
  install_resource "${PODS_ROOT}/QIMReactNativeLibrary/react-native-vector-icons/Fonts/Entypo.ttf"
  install_resource "${PODS_ROOT}/QIMReactNativeLibrary/react-native-vector-icons/Fonts/EvilIcons.ttf"
  install_resource "${PODS_ROOT}/QIMReactNativeLibrary/react-native-vector-icons/Fonts/Feather.ttf"
  install_resource "${PODS_ROOT}/QIMReactNativeLibrary/react-native-vector-icons/Fonts/FontAwesome.ttf"
  install_resource "${PODS_ROOT}/QIMReactNativeLibrary/react-native-vector-icons/Fonts/Foundation.ttf"
  install_resource "${PODS_ROOT}/QIMReactNativeLibrary/react-native-vector-icons/Fonts/Ionicons.ttf"
  install_resource "${PODS_ROOT}/QIMReactNativeLibrary/react-native-vector-icons/Fonts/MaterialCommunityIcons.ttf"
  install_resource "${PODS_ROOT}/QIMReactNativeLibrary/react-native-vector-icons/Fonts/MaterialIcons.ttf"
  install_resource "${PODS_ROOT}/QIMReactNativeLibrary/react-native-vector-icons/Fonts/Octicons.ttf"
  install_resource "${PODS_ROOT}/QIMReactNativeLibrary/react-native-vector-icons/Fonts/SimpleLineIcons.ttf"
  install_resource "${PODS_ROOT}/QIMReactNativeLibrary/react-native-vector-icons/Fonts/Zocial.ttf"
  install_resource "${PODS_CONFIGURATION_BUILD_DIR}/QIMUIKit/QIMSourceCode.bundle"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/General/Verders/QIMMWPhotoBrowser/Assets"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMNoteUI/CKEditor5.bundle"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMNoteUI/QTPassword/EditPasswordView.xib"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMRNKit/QIMRNKit.bundle"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/General/Verders/QIMSuperPlayer/SuperPlayer/Resource/SuperPlayer.bundle"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/片段/NetWorkSetting.html"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/片段/QIMMicroTourRoot.css"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/片段/QIMMicroTourRoot.html"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/片段/QTalkeula.html"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/片段/Startalkeula.html"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/Application/ViewController/Login/QIMLoginViewController.xib"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Audio/end.wav"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Audio/msg.wav"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Audio/right_answer.mp3"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Audio/新咨询的播报.wav"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Certificate/certificate.der"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Certificate/public_key.der"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Certificate/public_key.pem"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Certificate/pub_key.pem"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Certificate/pub_key_chat_dev.pem"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Certificate/pub_key_chat_release.pem"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Certificate/pub_key_talk_release.pem"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/DS-DIGI.TTF"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/DS-DIGIB.TTF"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/DS-DIGII.TTF"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/DS-DIGIT.TTF"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/iconfont.eot"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/iconfont.ttf"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/iconfont.woff"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/Ionicons.ttf"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/ops_opsapp.eot"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/ops_opsapp.svg"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/ops_opsapp.ttf"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/ops_opsapp.woff"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/QTalk-QChat.eot"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/QTalk-QChat.html"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/QTalk-QChat.svg"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/QTalk-QChat.ttf"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/QTalk-QChat.woff"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/方正兰亭黑简.TTF"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Stickers/EmojiOne.zip"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Stickers/qunar_camel.zip"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/QIMI18N.bundle"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/QIMUIKit.bundle"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIVendorKit/QIMArrowView/QIMArrowCellTableViewCell.xib"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIVendorKit/QIMDaePickerView/QIMWSDatePickerView.xib"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "${PODS_ROOT}/AMap3DMap/MAMapKit.framework/AMap.bundle"
  install_resource "${PODS_ROOT}/AlipaySDK-iOS/AlipaySDK.bundle"
  install_resource "${PODS_ROOT}/MJRefresh/MJRefresh/MJRefresh.bundle"
  install_resource "${PODS_CONFIGURATION_BUILD_DIR}/QIMCommon/QIMCommonResource.bundle"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/call_bg@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_audio_receive_normal@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_audio_receive_press@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_camera_white@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_invite_black@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_invite_blue@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_invite_gray@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_invite_white@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_loudspeaker_black@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_loudspeaker_blue@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_loudspeaker_gray@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_loudspeaker_white@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_mute_black@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_mute_blue@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_mute_gray@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_mute_white@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_reduce_black@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_reduce_blue@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_reduce_gray@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_reduce_white@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_video_black@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_video_blue@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_video_gray@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_avp_video_white@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_av_audio_micro_normal@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_av_audio_micro_press@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_av_audio_receive_normal@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_av_audio_receive_press@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_av_reply_message_normal@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_av_reply_message_press@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_call_reject_normal@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/icon_call_reject_press@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/im_skin_icon_audiocall_bg.jpg"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/portrait.jpg"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/portrait@2x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/voip_camera_icons_130x130_@1x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/voip_camera_icons_66x66_@3x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/voip_convert_icons_130x130_@1x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/icons/voip_convert_icons_66x66_@3x.png"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/sound/AVChat_busy.mp3"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/sound/AVChat_endCall.mp3"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/sound/AVChat_incoming.mp3"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/sound/AVChat_waitingForAnswer.mp3"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/sound/incomingRing.wav"
  install_resource "${PODS_ROOT}/QIMGeneralModule/QIMGeneralModule/WebRTC/RTC/sound/Message_system.mp3"
  install_resource "${PODS_CONFIGURATION_BUILD_DIR}/QIMKitVendor/QIMPinYin.bundle"
  install_resource "${PODS_ROOT}/QIMReactNativeLibrary/react-native-vector-icons/Fonts/Entypo.ttf"
  install_resource "${PODS_ROOT}/QIMReactNativeLibrary/react-native-vector-icons/Fonts/EvilIcons.ttf"
  install_resource "${PODS_ROOT}/QIMReactNativeLibrary/react-native-vector-icons/Fonts/Feather.ttf"
  install_resource "${PODS_ROOT}/QIMReactNativeLibrary/react-native-vector-icons/Fonts/FontAwesome.ttf"
  install_resource "${PODS_ROOT}/QIMReactNativeLibrary/react-native-vector-icons/Fonts/Foundation.ttf"
  install_resource "${PODS_ROOT}/QIMReactNativeLibrary/react-native-vector-icons/Fonts/Ionicons.ttf"
  install_resource "${PODS_ROOT}/QIMReactNativeLibrary/react-native-vector-icons/Fonts/MaterialCommunityIcons.ttf"
  install_resource "${PODS_ROOT}/QIMReactNativeLibrary/react-native-vector-icons/Fonts/MaterialIcons.ttf"
  install_resource "${PODS_ROOT}/QIMReactNativeLibrary/react-native-vector-icons/Fonts/Octicons.ttf"
  install_resource "${PODS_ROOT}/QIMReactNativeLibrary/react-native-vector-icons/Fonts/SimpleLineIcons.ttf"
  install_resource "${PODS_ROOT}/QIMReactNativeLibrary/react-native-vector-icons/Fonts/Zocial.ttf"
  install_resource "${PODS_CONFIGURATION_BUILD_DIR}/QIMUIKit/QIMSourceCode.bundle"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/General/Verders/QIMMWPhotoBrowser/Assets"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMNoteUI/CKEditor5.bundle"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMNoteUI/QTPassword/EditPasswordView.xib"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMRNKit/QIMRNKit.bundle"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/General/Verders/QIMSuperPlayer/SuperPlayer/Resource/SuperPlayer.bundle"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/片段/NetWorkSetting.html"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/片段/QIMMicroTourRoot.css"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/片段/QIMMicroTourRoot.html"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/片段/QTalkeula.html"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/片段/Startalkeula.html"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/Application/ViewController/Login/QIMLoginViewController.xib"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Audio/end.wav"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Audio/msg.wav"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Audio/right_answer.mp3"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Audio/新咨询的播报.wav"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Certificate/certificate.der"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Certificate/public_key.der"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Certificate/public_key.pem"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Certificate/pub_key.pem"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Certificate/pub_key_chat_dev.pem"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Certificate/pub_key_chat_release.pem"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Certificate/pub_key_talk_release.pem"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/DS-DIGI.TTF"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/DS-DIGIB.TTF"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/DS-DIGII.TTF"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/DS-DIGIT.TTF"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/iconfont.eot"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/iconfont.ttf"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/iconfont.woff"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/Ionicons.ttf"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/ops_opsapp.eot"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/ops_opsapp.svg"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/ops_opsapp.ttf"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/ops_opsapp.woff"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/QTalk-QChat.eot"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/QTalk-QChat.html"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/QTalk-QChat.svg"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/QTalk-QChat.ttf"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/QTalk-QChat.woff"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Fonts/方正兰亭黑简.TTF"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Stickers/EmojiOne.zip"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/Stickers/qunar_camel.zip"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/QIMI18N.bundle"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIKit/QIMUIKitResources/QIMUIKit.bundle"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIVendorKit/QIMArrowView/QIMArrowCellTableViewCell.xib"
  install_resource "${PODS_ROOT}/QIMUIKit/QIMUIVendorKit/QIMDaePickerView/QIMWSDatePickerView.xib"
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]] && [[ "${SKIP_INSTALL}" == "NO" ]]; then
  mkdir -p "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "${XCASSET_FILES:-}" ]
then
  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find -L "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "${PODS_ROOT}*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  if [ -z ${ASSETCATALOG_COMPILER_APPICON_NAME+x} ]; then
    printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" --output-partial-info-plist "${BUILD_DIR}/assetcatalog_generated_info.plist"
  else
    printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" --output-partial-info-plist "${BUILD_DIR}/assetcatalog_generated_info.plist" --app-icon "${ASSETCATALOG_COMPILER_APPICON_NAME}" --output-partial-info-plist "${TARGET_TEMP_DIR}/assetcatalog_generated_info_cocoapods.plist"
  fi
fi
