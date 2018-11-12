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
            "sha256": "2cd04b7c887808be030254e8d77de11d3fe9d4505c39d4b15d2664ffe8bf9301"
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
          "sha256": "7cf9f447ae7ed1c51722efc45e7f14418d15d7a1e143ac9f09a668999f4fc94d"
        }
      ]
    },
