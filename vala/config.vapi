/* config.vapi for SmartSim
 */

[CCode (cprefix = "", lower_case_cprefix = "", cheader_filename = "config.h")]
    namespace Config {
    [CCode (cname = "PACKAGE_VERSION")]
    public const string version;

    [CCode (cname = "PACKAGE_DATADIR")]
    public const string resourcesDir;

    [CCode (cname = "PACKAGE_LIBDIR")]
    public const string librariesDir;
}
