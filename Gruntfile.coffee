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

    connect:
      options:
        port: 9000
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


  # user defined tasks
  grunt.registerTask "default", [
  ]

  grunt.registerTask "serve", (target) ->
    if target is "dist"
      grunt.task.run([
        "connect:dist:keepalive"
      ])
    else
      grunt.task.run [
        "connect:livereload"
        "esteWatch"
      ]
