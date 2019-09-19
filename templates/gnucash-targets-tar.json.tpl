    {
      "name": "gnucash",
      "buildsystem": "cmake-ninja",
      "config-opts": [
           "-DBOOST_ROOT=/app"
      ],
      "cleanup": [
        "/share/info",
        "/share/doc/gnucash/*.csv",
        "/share/doc/gnucash/*.qif",
        "/share/doc/gnucash/*.gnucash",
        "/share/doc/gnucash/ChangeLog*",
        "/share/doc/gnucash/HACKING",
        "/share/doc/gnucash/README*",
        "/share/doc/gnucash/guile-hackers.txt",
        "/share/doc/gnucash/projects.html"
      ],
      "sources": [
      {
          "type": "archive",
          "url": "http://downloads.sourceforge.net/gnucash/gnucash (stable)/${revision}/gnucash-${revision}.tar.bz2",
          "sha256": "${code_checksum}"
        }
      ]
    },
    {
      "name": "gnucash-docs",
      "sources": [
        {
          "type": "archive",
          "url": "http://downloads.sourceforge.net/gnucash/gnucash-docs/gnucash-docs-${revision}.tar.gz",
          "sha256": "${docs_checksum}"
        }
      ]
    }
