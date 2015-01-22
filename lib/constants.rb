#User for app wide settings.
module Constants
    #Font aweseome icon classes.
    ICONS = {
        "Book" => "book",
        "Computer File" => "file-code-o",
        "Journal" => "newspaper-o",
        "Map" => "globe",
        "Musical Score" => "music",
        "Newspaper" => "newspaper-o",
        "Periodical Title" => "newspaper-o",
        "Sound Recording" => "volume-up",
        "Video" => "film",
    }

    FORMAT = {
        "Articles" => {
            icon: "fa-copy",
            info: "Full-text articles from scholarly journals, conference proceedings, book chapters, and other electronic content from the library’s subscription resources"
        },
        "Book" => {
            icon: "book",
            info: "Books and eBooks at Brown. In some cases books are requested from off-site storage or they are only available for use in the library."
        },
        "Computer File" => {
            icon: "file-code-o",
            info: "Electronic resources that are not primarily described by another format. For example: datasets, computer programs, or online services."
        },
        "Journal" => {
            icon: "newspaper-o",
            info: "Electronic resources that are not primarily described by another format. For example: datasets, computer programs, or online services."
        },
        "Sound Recording" => {
            icon: "volume-up",
            info: "Any item that is primarily record sound, either music or spoken word, in any format. Some resources may need to be searched in the specific database."
        }
        # "Journal" => "newspaper-o",
        # "Map" => "globe",
        # "Musical Score" => "music",
        # "Newspaper" => "newspaper-o",
        # "Periodical Title" => "newspaper-o",
        # "Sound Recording" => "Any item that is primarily record sound, either music or spoken word, in any format. Some resources may need to be searched in the specific database.",
        # "Video" => "film",
    }
end