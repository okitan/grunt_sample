"use strict"

module.exports = (grunt) ->
  # Load grunt tasks automatically
  require("load-grunt-tasks") grunt

  # config
  config =
    app:  "app"
    dist: "dist"
    tmp:  ".tmp"

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

    # grunt build
    concurrent:
      build: [ 'wiredep' ]

    wiredep:
      target:
        dest: config.tmp
        src: [
          'app/index.html',
        ]

  # user defined tasks
  grunt.registerTask "default", [
    "build"
  ]

  grunt.registerTask "build", [
    "concurrent:build",
  ]

  grunt.registerTask "serve", (target) ->
    if target is "dist"
      grunt.task.run([
        "build"
        "connect:dist:keepalive"
      ])
    else
      grunt.task.run [
        "build"
        "connect:livereload"
        "esteWatch"
      ]
