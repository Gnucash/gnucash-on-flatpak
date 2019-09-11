    {
      "name": "gnucash",
      "buildsystem": "cmake-ninja",
      "config-opts": [
           "-DBOOST_ROOT=/app"
      ],
      "cleanup": [
        "/share/info",
        "/share/doc/*.qif",
        "/share/doc/*.gnucash",
        "/share/doc/ChangLog*",
        "/share/doc/README*"
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
