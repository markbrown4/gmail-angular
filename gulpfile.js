// run 'npm install' and 'gulp'

var gulp = require('gulp');
var gutil = require('gulp-util');
var sass = require('gulp-sass');
var autoprefixer = require('gulp-autoprefixer');
var coffee = require('gulp-coffee');

var paths = {
  styles: {
    src:  'assets/scss/**/*.scss',
    dest: 'public/css'
  },
  scripts: {
    src:  'assets/coffee/**/*.coffee',
    dest: 'public/js'
  }
};

gulp.task('styles', function() {
  return gulp.src(paths.styles.src)
    .pipe(sass({errLogToConsole: true}))
    .pipe(autoprefixer(['last 2 versions', "ie 8"]))
    .pipe(gulp.dest(paths.styles.dest));
});

gulp.task('scripts', function() {
  return gulp.src(paths.scripts.src)
    .pipe(coffee())
    .on('error', gutil.log)
    .on('error', gutil.beep)
    .pipe(gulp.dest(paths.scripts.dest));
});

gulp.task('watch', function() {
  gulp.watch(paths.scripts.src, ['scripts']);
  gulp.watch(paths.styles.src, ['styles']);
});

gulp.task('default', ['styles', 'scripts', 'watch']);

