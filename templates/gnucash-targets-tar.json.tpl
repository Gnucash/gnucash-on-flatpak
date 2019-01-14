    {
      "name": "gnucash",
      "buildsystem": "cmake-ninja",
      "config-opts": [
           "-DBOOST_ROOT=/app"
      ],
      "cleanup": [
        "/share/info",
        "/share/doc"
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
