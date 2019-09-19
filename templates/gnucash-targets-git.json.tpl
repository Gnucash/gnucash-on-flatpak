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
