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

    esteWatch:
      options:
         dirs: [ "<%= config.app %>/**" ]
         livereload:
           enabled: true
           port: 35729
           extensions: [ 'jade', 'scss', 'coffee' ]
      jade: (filepath) ->
        [ "newer:jade:compile" ]
      scss: (filepath) ->
        [ "newer:sass:compile" ]
      coffee: (filepath) ->
        [ "newer:coffee:compile" ]


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
        'sass:compile'
        'coffee:compile'
      ]

    sass:
      options:
        dest: config.tmp
      compile:
        files: [
          {
            expand: true
            cwd: config.app
            src: "styles/*.scss"
            ext: ".css"
          }
        ]
    coffee:
      options:
        dest: config.tmp
      compile:
        files: [
          {
            expand: true
            cwd: config.app
            src: "scripts/*.coffee"
            ext: ".js"
          }
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

    useminPrepare:
      options:
        dest:    config.tmp
        staging: config.tmp
      html: "<%= config.tmp %>/index.html"
    usemin:
      html: "<%= config.tmp %>/{,*/}*.html"
    concat:
      options:
        dest: config.tmp
    cssmin:
      options:
        dest: config.tmp
    uglify:
      options:
        dest: config.tmp
    filerev:
      options:
        dest: config.dist
      compile:
        src: [
          "<%= config.tmp %>/styles/{,*/}*.css"
          "<%= config.tmp %>/scripts/{,*/}*.js"
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
              "styles/{,*/}*.css"
              "scripts/{,*/}*.js"
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
    "usemins"
    "postCompile"
  ]

  grunt.registerTask "preCompile", [
    "clean"
  ]

  grunt.registerTask "compile", [
    "concurrent:compile"
    "wiredep"
  ]

  grunt.registerTask "usemins", [
    'useminPrepare'
    'concat'
    'cssmin'
    'uglify'
    'filerev'
    'usemin'
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
