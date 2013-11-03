module.exports = (grunt) ->

  require("matchdep").filterDev("grunt-*").forEach (contrib) ->
    grunt.log.ok [contrib + " is loaded"]
    grunt.loadNpmTasks contrib

  config =
    tmp: ".tmp"
    dist: "dist"
    src: "src"
    vendor: "bower_components"

  umdReturnExportsGlobalWrapper =
    start:
      """
      (function (root, factory) {
          if (typeof define === 'function' && define.amd) {
              define(['hiv'], function (hiv) {
                  return (root.hiv = factory(hiv));
              });
          } else if (typeof exports === 'object') {
              module.exports = factory(root.hiv);
          } else {
              root.hiv = factory(root.hiv);
          }
      }(this, function (hiv) {
      \n
      """
    end:
      """
          return hiv;
      }));
      """

  grunt.initConfig
    config: config
    clean:
      dist:
        files: [
          dot: true
          src: ["<%= config.dist %>/*", "!<%= config.dist %>/.git*"]
        ]
      tmp:
        files: [
          dot: true
          src: ["<%= config.tmp %>/*"]
        ]

    copy:
      vendor:
        expand: true
        cwd: "<%= config.vendor %>"
        src: ["**/*.js", "!**/*.min.js"]
        dest: '<%= config.tmp %>/vendor/'
        filter: "isFile"

    coffee:
      dist:
        options:
          bare: true
        files: [
          expand: true
          cwd: "<%= config.src %>"
          src: "{,*/,*/*/}*.coffee"
          dest: "<%= config.tmp %>"
          ext: ".js"
        ]

    requirejs:
      compile:
        options:
          name: "main"
          mainConfigFile: "<%= config.tmp %>/config.js"
          baseUrl: "<%= config.tmp %>/."
          optimize: "none"
          wrap: umdReturnExportsGlobalWrapper
          include: [
            "../node_modules/requirejs/require.js"
          ]
          out: "<%= config.dist %>/hiv-full.js"

    watch:
      dist:
        files: "<%= config.src %>/**/*.coffee"
        tasks: [
          "coffee:dist"
          "requirejs"
        ]
      vendor:
        files: "<%= config.vendor %>/**/*"
        tasks: ["copy:vendor"]



  # Default task.
  grunt.registerTask "default", ["coffee", "copy", "requirejs"]
