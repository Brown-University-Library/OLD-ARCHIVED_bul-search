#User for app wide settings.
module Constants
    #Format specific information - presently icon and helper text.
    #These should match the formats stored in solr:
    #https://github.com/Brown-University-Library/bul-traject/blob/master/lib/translation_maps/format.rb
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
        "Map" => {
            icon: "globe",
            info: "Physical and online maps held in the Library collection."
        },
        "Mixed Materials" => {
            icon: nil,
            info: "A collection of materials that do not include a dominant format."
        },
        "Musical Score" => {
            icon: "music",
            info: "Notated music in print, online, or in microfilm."
        },
        "Newspaper" => {
            icon: "newspaper-o",
            info: "Historic and current newspaper articles."
        },
        "Periodical Title" => {
            icon: "newspaper-o",
            info: "Titles of journals, newspapers, magazines, conference proceedings and other types of periodicals, but not the individual articles."
        },
        "Resource Guides" => {
            icon: nil,
            info: "Library journals, databases and other resources selected by topic as a great starting point for research."
        },
        "Sound Recording" => {
            icon: "volume-up",
            info: "Any item that is primarily record sound, either music or spoken word, in any format. Some resources may need to be searched in the specific database."
        },
        "Thesis/Dissertation" => {
            icon: "file-text",
            info: "Brown theses/dissertations which are available in a physical format or through ProQuest. Most theses and dissertations written after 2008 will be found in the Brown Digital Repository holdings."
        },
        "Video" => {
            icon: "film",
            info: "Movies and the popular DVD collection, plus some streaming videos."
        },
        "3D object" => {
            icon: nil,
            info: "3D artifacts such as sculptures, models, games, clothing, or specimens."
        },
        "Visual Material" => {
            icon: "file-image-o",
            info: ""
        },
        "Archives/Manuscripts" => {
            icon: "archive",
            info: ""
        }
    }

    #Used on individual record pages.
    NOTES_DISPLAY = [
      {label: "Note", tag: "500"},
      {label: "Dissertation information", tag: "502"},
      {label: "Bibliography", tag: "504"},
      {label: "Table of Contents", tag: "505"},
      {label: "Restrictions", tag: "506"},
      {label: "Scale of Material", tag: "507"},
      {label: "Other Formats", tag: "530"},
      {label: "Reproduction Information", tag: "533"},
      {label: "Original Format", tag: "534"},
      {label: "System Requirements", tag: "538"},
      {label: "Language", tag: "546"},
      {label: "Issuing Body", tag: "550"},
      {label: "Indexes", tag: "555"},
      {label: "Information about Brown's Copy", tag: "590", all: true}
    ]
end