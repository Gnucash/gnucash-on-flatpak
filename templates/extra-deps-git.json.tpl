    {
        "name": "pcre",
        "config-opts": [
            "--enable-unicode-properties"
        ],
        "cleanup": ["*"],
        "sources": [
        {
            "type": "archive",
            "url": "http://prdownloads.sourceforge.net/pcre/pcre-8.42.tar.bz2",
            "sha1": "df0d1c2ff04c359220cb902539a6e134af4497f4"
        }
        ]
    },
    {
      "name": "swig",
      "config-opts": [
            "-with-boost-libs=/app/lib",
            "--without-alllang",
            "--with-guile=/app/bin/guile",
            "--with-guile-config=/app/bin/guile-config"
      ],
      "cleanup": ["*"],
      "sources": [
        {
          "type": "archive",
          "url": "http://prdownloads.sourceforge.net/swig/swig-3.0.12.tar.gz",
          "sha1": "5cc1af41d041e4cc609580b99bb3dcf720effa25"
        }
      ]
    },
