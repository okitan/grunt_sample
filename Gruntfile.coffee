"use strict"

module.exports = (grunt) ->
  # Load grunt tasks automatically
  require("load-grunt-tasks") grunt

  # config
  config =
    app:  "app"
    dist: "dist"
    tmp:  "tmp"

  grunt.initConfig
    config: config

    # grunt serve
    connect:
      options:
        port: 9000
        useAvailablePort: true
        open: true
        livereload: 35729
        hostname: "localhost"
      livereload:
        options:
          base: "<%= config.tmp %>"
          middleware: (connect) ->
            [
              connect.static(config.tmp)
              connect().use("/bower_components", connect.static("./bower_components"))
              connect.static(config.app)
            ]
      dist:
        options:
          base: "<%= config.dist %>"
          livereload: false

    # pre build
    clean:
      tmp:  config.tmp
      dist:
        files: [
          dot: true
          src: [
            "<%= config.dist %>/*"
            "!<%= config.dist %>/.git*"
          ]
        ]

    # build
    concurrent:
      compile: [
        'jade:compile'
      ]
      minify: [
      ]

    jade:
      options:
        pretty: true
      compile:
        files: [
          expand: true
          cwd:  "<%= config.app %>/jade"
          src:  "*.jade"
          dest: config.tmp
          ext: '.html'
        ]
    wiredep: # this overwrite file itself...
      compile:
        src: [
          "<%= config.tmp %>/{,*/}*.html"
        ]

    # post build
    copy:
      dist:
        files: [
          {
            expand: true
            dot:    true
            cwd:    config.app
            dest:   config.dist
            src: [
              ".htaccess"
              "*.{ico,png,txt}"
               "images/{,*/}*.webp"
              "{,*/}*.html"
              "styles/fonts/{,*/}*.*"
            ]
          }
          {
            expand: true
            cwd:    config.tmp
            dest:   config.dist
            src: [
              "{,*/}*.html"
            ]
          }
        ]


  # user defined tasks
  grunt.registerTask "default", [
    "build"
  ]

  grunt.registerTask "build", [
    "preCompile"
    "compile"
    "postCompile"
  ]

  grunt.registerTask "preCompile", [
    "clean"
  ]

  grunt.registerTask "compile", [
    "concurrent:compile"
    "wiredep"
  ]

  grunt.registerTask "postCompile", [
    "copy:dist"
  ]

  grunt.registerTask "serve", (target) ->
    if target is "dist"
      grunt.task.run [
        "build"
        "connect:dist:keepalive"
      ]
    else
      grunt.task.run [
        "clean:tmp"
        "compile"
        "connect:livereload"
        "esteWatch"
      ]
