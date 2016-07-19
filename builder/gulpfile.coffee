##################################################################################
##### Зависимости
##################################################################################

# node modules
fs = require 'fs'
pngcrush = require 'imagemin-pngcrush'

# gulp modules
gulp = require 'gulp'
gulpLoadPlugins = require 'gulp-load-plugins'
g = gulpLoadPlugins()


##################################################################################
##### Пути к файлам
##################################################################################

src =
	path: "../src"

	styles:
		all: "../src/styles/*.styl"
		path: "../src/styles"
		main: "../src/styles/main.styl"

	scripts:
		local:
			all: "../src/scripts/local/**/*.coffee"
		vendor:
			all: "../src/scripts/vendor/**/*.*"
			deps: [
				# "jquery/dist/jquery.min.js"
			]

	images:
		all: "../src/images/**/*.*"
		path: "../src/images"

	fonts:
		all: "../src/fonts/**/*.*"
		path: "../src/fonts"

	templates:
		all: "../src/*.jade"
		path: "../src"

built =
	path: "../built"

	styles:
		all: "../built/styles/*.css"
		path: "../built/styles"
		main: "../built/styles/main.css"

	scripts:
		all: "../built/scripts/**/*.*"
		path: "../built/scripts"
		local:
			all: "../built/scripts/local/**/*.*"
			path: "../built/scripts/local"
		vendor:
			all: "../built/scripts/vendor/**/*.*"
			path: "../built/scripts/vendor"

	images:
		all: "../built/images/**/*.*"
		path: "../built/images"

	fonts:
		all: "../built/fonts/**/*.*"
		path: "../built/fonts"


##################################################################################
##### Функции-помощники
##################################################################################

# Если случается ошибка при работе галпа, воспроизводтся звук
consoleErorr = (err) ->
	g.util.beep()
	console.log err.message

	return

# Сервер
gulp.task 'connect', ->
	g.connect.server
		port: 1337
		livereload: on
		root: '../built'


##################################################################################
##### Таски
##################################################################################

# Перенос скриптов из папки vendor в built
gulp.task 'vendor', ->
	gulp.src src.scripts.vendor.all
		.pipe g.ignore.include(src.scripts.vendor.deps)
		.pipe gulp.dest built.scripts.vendor.path
		.pipe do g.connect.reload

# Компиляция coffee в js
gulp.task 'coffee', ->
	gulp.src src.scripts.local.all
		.pipe g.plumber
			errorHandler: consoleErorr
		.pipe g.coffee
			bare: false
		.pipe g.uglify()
		.pipe gulp.dest built.scripts.local.path
		.pipe do g.connect.reload

gulp.task 'scripts', ['vendor', 'coffee']

# Компиляция stylus в css и добавление префиксов
gulp.task 'styles', ->
	gulp.src src.styles.main
		.pipe g.plumber
			errorHandler: consoleErorr
		.pipe g.stylus()
		.pipe g.autoprefixer
			browsers: ['last 7 versions']
			cascade: false
		.pipe g.minifyCss
			advanced: false
			keepBreaks: false
		.pipe gulp.dest built.path
		.pipe do g.connect.reload

# Копирование картинок из src в built
gulp.task 'images', ->
	gulp.src src.images.all
		.pipe g.plumber
			errorHandler: consoleErorr
		.pipe g.imagemin
			progressive: true
			svgoPlugins: [
				removeViewBox: false
			]
			use: [
				pngcrush()
			]
		.pipe gulp.dest built.images.path
		.pipe do g.connect.reload

# Копирование шрифтов из src в built
gulp.task 'fonts', ->
	gulp.src src.fonts.all
		.pipe g.plumber
			errorHandler: consoleErorr
		.pipe gulp.dest built.fonts.path
		.pipe do g.connect.reload

# Генерирование jade шаблонов
gulp.task 'jade', ->
	gulp.src src.templates.all
		.pipe g.plumber
			errorHandler: consoleErorr
		.pipe g.jade
			pretty: '\t'
		.pipe gulp.dest built.path
		.pipe do g.connect.reload


##################################################################################
##### Таски оптимизации
##################################################################################

# Оптимизация скриптов
# gulp.task 'scripts:min', ->
# 	gulp.src built.scripts.local.all
# 		.pipe g.plumber
# 			errorHandler: consoleErorr
# 		.pipe g.uglify()
# 		.pipe gulp.dest built.scripts.local.path

# Оптимизация картинок
# gulp.task 'images:min', ->
# 	gulp.src built.images.all
# 		.pipe g.plumber
# 			errorHandler: consoleErorr
# 		.pipe g.imagemin
# 			progressive: true
# 			svgoPlugins: [
# 				removeViewBox: false
# 			]
# 			use: [
# 				pngcrush()
# 			]
# 		.pipe gulp.dest built.images.path

# Оптимизация стилей
# gulp.task 'styles:min', ->
# 	gulp.src built.styles.main
# 		.pipe g.plumber
# 			errorHandler: consoleErorr
# 		.pipe g.minifyCss
# 			advanced: false
# 			keepBreaks: false
# 		.pipe gulp.dest built.path


##################################################################################
##### Отслеживанием изменение файлов
##################################################################################

gulp.task 'watch', ->
	gulp.watch src.scripts.local.all, ['coffee']
	gulp.watch src.scripts.vendor.all, ['vendor']
	gulp.watch src.styles.all, ['styles']
	gulp.watch src.images.all, ['images']
	gulp.watch src.fonts.all, ['fonts']
	gulp.watch src.templates.all, ['jade']
	return


##################################################################################
##### Таски по группам
##################################################################################

# Выполнение всех тасков
gulp.task 'dev', ['styles', 'scripts', 'images', 'fonts', 'jade']

# Dev таск для разработки с отслеживанием измнений файлов и компиляцией их на лету
gulp.task 'default', ['dev', 'connect', 'watch']

# Минификация js, css и оптимизация изображений
# gulp.task 'minify', ['scripts:min', 'images:min', 'styles:min']

# Подготовка проекта для продакшена. Исполнение всех задач + минификация файлов
# gulp.task 'prod', ['dev'], ->
# 	gulp.start 'minify'
