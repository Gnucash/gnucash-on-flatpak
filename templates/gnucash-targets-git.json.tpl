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
      "post-install": [
        "sed -i 's/org.gnucash.Gnucash/org.gnucash.GnuCash/g' /app/share/appdata/*.xml"
      ],
      "sources": [
        {
          "type": "git",
          "path": "${code_repodir}",
          "branch": "${revision}"
        }
      ]
    },
    {
      "name": "gnucash-docs",
      "sources": [
        {
          "type": "git",
          "path": "${docs_repodir}",
          "branch": "${revision}"
        }
      ]
    }
