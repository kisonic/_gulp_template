##################################################################################
##### Зависимости
##################################################################################

# node modules
fs = require 'fs'
yaml = require 'js-yaml'
pngcrush = require 'imagemin-pngcrush'

# gulp modules
gulp = require 'gulp'
# connect = require 'gulp-connect'
gulpLoadPlugins = require 'gulp-load-plugins'
g = gulpLoadPlugins()

# config.yml file
config = yaml.load(fs.readFileSync("config.yml", "utf8"))


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
	gulp.src config.src.scripts.vendor.all
		.pipe gulp.dest config.built.scripts.vendor.path

# Компиляция coffee в js
gulp.task 'coffee', ->
	gulp.src config.src.scripts.local.all
		.pipe g.plumber
			errorHandler: consoleErorr
		.pipe g.coffee
			bare: true
		.pipe gulp.dest config.built.scripts.local.path
		.pipe do g.connect.reload

gulp.task 'scripts', ['vendor', 'coffee']

# Компиляция stylus в css и добавление префиксов
gulp.task 'stylus', ->
	gulp.src config.src.styles.all
		.pipe g.plumber
			errorHandler: consoleErorr
		.pipe g.stylus()
		.pipe g.autoprefixer
			browsers: ['last 5 versions']
			cascade: false
		.pipe g.csscomb()
		.pipe gulp.dest config.built.styles.path
		.pipe do g.connect.reload

# Копирование картинок из src в built
gulp.task 'images', ->
	gulp.src config.src.images.all
		.pipe gulp.dest config.built.images.path

# Копирование шрифтов из src в built
gulp.task 'fonts', ->
	gulp.src config.src.fonts.all
		.pipe gulp.dest config.built.fonts.path

# Генерирование jade шаблонов
gulp.task 'jade', ->
	gulp.src config.src.templates.all
		.pipe g.plumber
			errorHandler: consoleErorr
		.pipe g.jade
			pretty: true
		.pipe gulp.dest config.built.path
		.pipe do g.connect.reload


##################################################################################
##### Такси оптимизации
##################################################################################

# Оптимизация скриптов
gulp.task 'scripts:min', ->
	gulp.src config.built.scripts.local.all
		.pipe g.plumber
			errorHandler: consoleErorr
		.pipe g.uglify()
		.pipe gulp.dest config.built.scripts.local.path

# Оптимизация картинок
gulp.task 'images:min', ->
	gulp.src config.built.images.all
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
		.pipe gulp.dest config.built.images.path

gulp.task 'styles:min', ->
	gulp.src config.built.styles.all
		.pipe g.plumber
			errorHandler: consoleErorr
		.pipe g.minifyCss()
		.pipe gulp.dest config.built.path


# Отслеживанием изменение файлов
gulp.task 'watch', ->
	gulp.watch config.src.scripts.local.all, ['coffee']
	gulp.watch config.src.scripts.vendor.all, ['vendor']
	gulp.watch config.src.styles.all, ['stylus']
	gulp.watch config.src.images.all, ['images']
	gulp.watch config.src.templates.all, ['jade']

	return


##################################################################################
##### Таски по группам
##################################################################################

# Выполнение всех тасков
gulp.task 'default', ['stylus', 'scripts', 'images', 'jade']

# Dev таск для разработки с отслеживанием измнений файлов и компиляцией их на лету
gulp.task 'dev', ['default', 'connect', 'watch']

# минификация js, css и оптимизация изображений.
gulp.task 'minify', ['scripts:min', 'styles:min', 'images:min']

# Подготовка проекта для продакшена. Исполнение всех задач + минификация файлов
gulp.task 'prod', ['default'], ->
	gulp.start 'minify'