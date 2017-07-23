/*
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *   Filename: main.vala
 *
 *   Copyright Ashley Newson 2013
 */



/**
 * Describes the direction a signal is meant to flow.
 */
public enum Flow {
    NONE,
    IN,
    OUT,
    BIDIRECTIONAL
}

/**
 * Describes the direction an object is facing or drawn.
 */
public enum Direction {
    NONE,
    RIGHT,
    DOWN,
    LEFT,
    UP,
    HORIZONTAL,
    VERTICAL,
    DIAGONAL
}

/**
 * Stores a comparison of versions.
 */
public enum VersionComparison {
    EQUAL,
    LESS,
    GREATER
}


/**
 * Contains the main function. Handles initial load up and contains
 * package information.
 */
public class Core {
    /**
     * Stores all primitive (built-in) components.
     */
    public static ComponentDef[] standardComponentDefs;

    public const string programName = "SmartSim";
    public const string[] authorsStrings = {"Ashley Newson <ashleynewson@smartsim.org.uk>", null};
    public const string websiteString = "http://www.smartsim.org.uk";
    public const string shortVersionString = Config.version;
    public const string versionString = Config.version + "";
    public const string copyrightString = "Ashley Newson 2013";
    public const Gtk.License licenseType = Gtk.License.GPL_3_0;
    public const string licenseName = "Public Package - GNU GPL 3.0 - Freely Distributable";
    public const string shortLicenseText =
"""This software, SmartSim, and its corresponding resource files are the
intellectual property of Ashley Newson. This package is released under
the GNU General Public License 3.0. A provided "COPYING" file provides
the full license text.

This package may be provided with the Gtk and Rsvg Libraries. The
licenses of these libraries are included in the "GTK_COPYING" and
"RSVG_COPYING" files.

SmartSim is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public Licence as published by the
Free Software Foundation; either version 3 of the Licence, or (at your
option) any later version.

SmartSim is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licence
for more details.

You should have received a copy of the GNU General Public Licence along
with SmartSim. If not, see:
  http://www.gnu.org/licenses/
""";
    public static string fullLicenseText = "";


    private static bool _versionIgnored = false;
    public static bool version_ignored(string extra = "") {
        if (_versionIgnored == true) {
            return true;
        }
        switch (
            BasicDialog.ask_generic(
                null,
                Gtk.MessageType.WARNING,
                "Warning:\nThe version of SmartSim used to save a file being loaded is greater than the current version you are using.\nThis version might not be compatible with the saved file. It could behave unpredictably, or cause loss of data upon saving.\n" + extra,
                {"Continue", "Continue For All Files", "Cancel Loading"}
            )
        ) {
            case 0:
                return true;
            case 1:
                _versionIgnored = true;
                return true;
            case 2:
            default:
                _versionIgnored = false;
                return false;
        }
    }
    

    /**
     * The beginning point of execution. Starts load up and creates a
     * single DesignerWindow.
     */
    public static int main(string[] args) {
        string[] projectsToOpen = {};

        stdout.printf("%s\n", Core.programName);
        stdout.printf("\t%s\n", Core.versionString);
        stdout.printf("Copyright: %s\n", Core.copyrightString);
        stdout.printf("License: %s\n", Core.licenseName);

        Core.fullLicenseText = Core.load_string_from_file("COPYING");

        for (int i = 1; i < args.length; i++) {
            string arg = args[i];
            switch (arg) {
            case "--version":
                return 0;
            case "--license":
                stdout.printf("%s\n", Core.licenseName);
                stdout.printf("%s\n", Core.fullLicenseText);
                return 0;
            default:
                if (arg.substring(0, 2) == "--") {
                    stderr.printf("Unrecognised command \"%s\".\n", arg);
                } else {
                    /* Assume it is a project file. */
                    projectsToOpen += arg;
                }
                break;
            }
        }

        stdout.printf("Loading System...\n");

        Gtk.init(ref args);

        stdout.printf("Loading Place-holder Graphic\n");
        try {
            Graphic.placeHolder = new Graphic.from_file(Config.resourcesDir + "images/graphics/placeholder");
        } catch (GraphicLoadError error) {
            stdout.printf("Could not load place-holder graphic: %s\n", error.message);
        }

        stdout.printf("Loading Components\n");
        Core.load_standard_defs();

        if (projectsToOpen.length == 0) {
            new DesignerWindow();
        } else {
            foreach (string filename in projectsToOpen) {
                new DesignerWindow.with_project_from_file(filename);
            }
        }

        stdout.printf("Ready\n");

        Gtk.main();

        stdout.printf("Program Terminating...\n");

        PluginComponentManager.unregister_all();

        stdout.printf("Program Terminated.\n");

        return 0;
    }

    /**
     * Loads all primitive (built-in) components.
     */
    private static void load_standard_defs() {
        ComponentDef[] standardComponentDefs = {};

        try {
            standardComponentDefs += new BufferComponentDef();
            standardComponentDefs += new AndComponentDef();
            standardComponentDefs += new OrComponentDef();
            standardComponentDefs += new XorComponentDef();
            standardComponentDefs += new TristateComponentDef();
            standardComponentDefs += new MultiplexerComponentDef();
            standardComponentDefs += new PeDFlipflopComponentDef();
            standardComponentDefs += new TFlipflopComponentDef();
            standardComponentDefs += new MemoryComponentDef();
            standardComponentDefs += new ConstantComponentDef();
            standardComponentDefs += new ClockComponentDef();
            standardComponentDefs += new ToggleComponentDef();
            standardComponentDefs += new ReaderComponentDef();
            standardComponentDefs += new BasicSsDisplayComponentDef();
        } catch (ComponentDefLoadError error) {
            Gtk.MessageDialog messageDialog = new Gtk.MessageDialog(
                null,
                Gtk.DialogFlags.MODAL,
                Gtk.MessageType.ERROR,
                Gtk.ButtonsType.OK,
                "There was a fatal error trying to load the built in components:\n%s",
                error.message
            );

            messageDialog.run();
            messageDialog.destroy();
            Process.exit(1);
        }
        Core.standardComponentDefs = standardComponentDefs;
    }

    private static string load_string_from_file(string filename) {
        FileStream file = FileStream.open(Config.resourcesDir + filename, "r");
        uint8[] data;
        long length;

        if (file == null) {
            stderr.printf("File could not be opened.\n");
            return "Error opening file! Please see the \"" + filename + "\" file.\n";
        }

        file.seek(0, FileSeek.END);
        length = file.tell();
        file.seek(0, FileSeek.SET);

        data = new uint8[length+1];

        if (length == file.read(data)) {
            data[length] = 0;
            return (string)data;
        } else {
            stderr.printf ("File could not be read.\n");
            return "Error reading file! Please see the \"" + filename + "\" file.\n";
        }
    }

    /**
     * Returns //standardComponentDefs//.
     */
    public static ComponentDef[] get_standard_defs() {
        return standardComponentDefs;
    }

    /**
     * Returns the relative filename based upon the current working directory
     * or a specified one.
     */
    public static string relative_filename(string rawTargetFilename, string rawReferenceFilename = Environment.get_current_dir()) { // May need to be replaced!
        string targetFilename = rawTargetFilename.replace(GLib.Path.DIR_SEPARATOR_S, "/");
        string referenceFilename = rawReferenceFilename.replace(GLib.Path.DIR_SEPARATOR_S, "/");

        string[] referenceDirectories = {};
        string[] targetDirectories = {};

        string result = "";

        int startIndex = 0;
        int endIndex = 0;

        if (!GLib.Path.is_absolute(targetFilename)) {
            return rawTargetFilename;
        }

        while (true) { // breaks
            startIndex = endIndex + 1;
            endIndex = referenceFilename.index_of("/", startIndex);
            if (endIndex == -1) {
                break;
            } else {
                referenceDirectories += referenceFilename.slice(startIndex, endIndex);
            }
        }

        startIndex = 0;
        endIndex = 0;

        while (true) { // breaks
            startIndex = endIndex + 1;
            endIndex = targetFilename.index_of("/", startIndex);
            if (endIndex == -1) {
                break;
            } else {
                targetDirectories += targetFilename.slice(startIndex, endIndex);
            }
        }

        int commonCount;

        for (commonCount = 0; commonCount < referenceDirectories.length; commonCount++) {
            if (referenceDirectories[commonCount] != targetDirectories[commonCount]) {
                break;
            }
        }

        for (int i = commonCount; i < referenceDirectories.length; i++) {
            result += "../"; // Is there a const for ".."?
        }

        for (int i = commonCount; i < targetDirectories.length; i++) {
            result += targetDirectories[i] + "/"; // Is there a const for ".."?
        }

        result += GLib.Path.get_basename(targetFilename);

        return result;
    }

    /**
     * Returns the absolute filename based upon the current working directory
     * or a specified one.
     */
    public static string absolute_filename(string filename, string pwd = Environment.get_current_dir()) {
        if (GLib.Path.is_absolute(filename) == true) {
            return filename;
        }
        return reduce_filename(GLib.Path.build_filename(pwd, filename));
    }

    /**
     * Simplifies a filename. For example, "./a/b\..\c/./d" would reduce to
     * "a/c/d"
     */
    public static string reduce_filename(string rawFilename) {
        string filename = rawFilename.replace(GLib.Path.DIR_SEPARATOR_S, "/");
        string[] rawParts = filename.split("/");
        string[] reducedParts = {};

        foreach (string part in rawParts) {
            switch (part) {
            case ".":
                // Do nothing.
                break;
            case "..":
                if (reducedParts.length == 0) {
                    reducedParts += "..";
                } else if (reducedParts[reducedParts.length-1] == "..") {
                    reducedParts += "..";
                } else {
                    reducedParts.length--;
                }
                break;
            default:
                reducedParts += part;
                break;
            }
        }

        return string.joinv("/", reducedParts);
    }

    /**
     * Compares version strings and returns a VersionComparison such that
     * If //whatVersion// is ahead of //withVersion//, GREATER is returned.
     */
    public static VersionComparison compare_versions(string whatVersion, string withVersion = Core.shortVersionString) {
        int[] whatNumbers = version_to_numbers(whatVersion);
        int[] withNumbers = version_to_numbers(withVersion);

        for (int i = 0; i < whatNumbers.length && i < withNumbers.length; i++) {
            if (whatNumbers[i] > withNumbers[i]) {
                return VersionComparison.GREATER;
            } else if (whatNumbers[i] < withNumbers[i]) {
                return VersionComparison.LESS;
            }
        }
        if (whatNumbers.length > withNumbers.length) {
            return VersionComparison.GREATER;
        } else if (whatNumbers.length < withNumbers.length) {
            return VersionComparison.LESS;
        }
        return VersionComparison.EQUAL;
    }

    /**
     * Translates a version string to an array of numbers.
     */
    private static int[] version_to_numbers(string version) {
        int[] numbers = {};
        uint8[] data = version.data;
        string number = "";

        foreach (uint8 datum in data) {
            switch (datum) {
            default: // Includes null character
                if (number != "") {
                    numbers += int.parse(number);
                    number = "";
                }
                break;
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9':
                number = "%s%c".printf(number, datum);
                break;
            }
        }
        if (number != "") {
            numbers += int.parse(number);
            number = "";
        }

        return numbers;
    }
}
