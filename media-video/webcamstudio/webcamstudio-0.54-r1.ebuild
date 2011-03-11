# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
JAVA_PKG_IUSE="doc source"
WANT_ANT_TASKS="ant-nodeps ant-junit4 ant-junit"

inherit eutils linux-mod subversion fdo-mime java-pkg-2 java-ant-2

DESCRIPTION="Creates virtual webcam to broadcast over the internet."
HOMEPAGE="http://www.ws4gl.org/"
ESVN_REPO_URI="https://webcamstudio.svn.sourceforge.net/svnroot/webcamstudio/trunk@849"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=virtual/jdk-1.6
	>=media-libs/gst-plugins-base-0.10
	>=media-libs/gst-plugins-good-0.10
	>=media-libs/gst-plugins-bad-0.10
	>=media-libs/gst-plugins-ugly-0.10
	media-plugins/gst-plugins-meta:0.10[ffmpeg,flac,lame,theora,v4l,v4l2,vorbis]
	media-plugins/gst-plugins-x264:0.10
	dev-java/appframework
	dev-java/commons-cli:1
	dev-java/commons-codec
	dev-java/commons-httpclient:3
	dev-java/jna
	dev-java/jsr305
	dev-java/log4j
	dev-java/sun-javamail
	dev-java/slf4j-api
	dev-java/slf4j-nop
	dev-java/swing-worker
	dev-java/gstreamer-java"


MODULE_NAMES="webcamstudio(misc:${S}/vloopback)"
CONFIG_CHECK="VIDEO_DEV"

java_prepare() {
        cd "${S}/libraries"
        rm -v appframework*.jar commons-*.jar gstreamer-*.jar log4j-*.jar slf4j-*.jar swing-*.jar|| die

        java-pkg_jar-from appframework appframework.jar appframework-1.0.3.jar
        java-pkg_jar-from commons-cli-1 commons-cli.jar commons-cli-1.2.jar
        java-pkg_jar-from commons-codec commons-codec.jar commons-codec-1.2.jar
        java-pkg_jar-from commons-httpclient-3 commons-httpclient.jar commons-httpclient-3.1.jar
        java-pkg_jar-from gstreamer-java gstreamer-java.jar gstreamer-java-1.3.jar
        java-pkg_jar-from swing-worker swing-worker.jar swing-worker-1.1.jar
        java-pkg_jar-from jna,jsr305,log4j,sun-javamail,slf4j-api,slf4j-nop
}

pkg_setup() {
	java-pkg-2_pkg_setup

	linux-mod_pkg_setup
	BUILD_PARAMS="KERNEL_DIR=${KV_DIR}"
	BUILD_TARGETS="all"
	MODULESD_WEBCAMSTUDIO_ENABLED="yes"
}

src_compile() {
	java-pkg-2_src_compile

	linux-mod_src_compile
}

src_install() {
	java-pkg_dojar dist/WebcamStudio.jar

	# Install only non-portage .jar bundled files
	java-pkg_jarinto /opt/${PN}/lib
	java-pkg_dojar libraries/gdata-*.jar
	java-pkg_dojar libraries/google-*.jar
	java-pkg_dojar libraries/jcl104-over-slf4j-*.jar
	java-pkg_dojar libraries/jtwitter.jar
	java-pkg_dojar libraries/netty-*.jar

	dodoc latestbuild/README.TXT

	java-pkg_dolauncher ${PN} \
		--main webcamstudio.Main \
		--jar WebcamStudio.jar

	newicon "${S}/debian/webcamstudio.png" webcamstudio.png
	domenu "${S}/debian/${PN}.desktop"

        use doc && java-pkg_dojavadoc dist/javadoc
        use source && java-pkg_dosrc src/*

	linux-mod_src_install
}

pkg_postinst() {
	linux-mod_pkg_postinst
	fdo-mime_desktop_database_update

	elog "To use WebcamStudio you need to have the \"webcamstudio\" module"
	elog "loaded first."
	elog ""
	elog "If you want to do it automatically, please add \"webcamstudio\" to:"
	if has_version sys-apps/openrc; then
		elog "/etc/conf.d/modules"
	else
		elog "/etc/modules.autoload.d/kernel-${KV_MAJOR}.${KV_MINOR}"
	fi
	elog ""
}

pkg_postrm() {
	linux-mod_pkg_postrm
	fdo-mime_desktop_database_update
}

