project('expidus-terminal', 'vala', 'c', license: 'GPL-3.0-only', version: '0.1.0-prealpha')

gnome = import('gnome')

prefix = get_option('prefix')
bindir = prefix / get_option('bindir')
datadir = prefix / get_option('datadir')
libdir = prefix / get_option('libdir')
libexecdir = prefix / get_option('libexecdir')
localstatedir = get_option('localstatedir')

longver = '@0@'.format(meson.project_version())
shortver = longver
git = find_program('git', native: true, required: false)
if git.found()
	git_commit = run_command([git, 'rev-parse', '--short', 'HEAD'])
	git_branch = run_command([git, 'rev-parse', '--abbrev-ref', 'HEAD'])
	if git_commit.returncode() == 0 and git_branch.returncode() == 0
    shortver = '@0@-@1@'.format(meson.project_version(), git_commit.stdout().strip())
		longver = '@0@ (branch \'@1@\')'.format(shortver, git_branch.stdout().strip())
	endif
endif

libtokyo = dependency('tokyo-gtk3', fallback: ['libtokyo', 'libtokyo_gtk3_dep'], required: false)
if not libtokyo.found()
  libtokyo_subproject = subproject('libtokyo')
  libtokyo = libtokyo_subproject.get_variable('libtokyo_gtk3_dep')
endif

handy = dependency('libhandy-1', required: false, version: '>= 1.6.0')
vte = dependency('vte-2.91', required: true, version: '>= 0.68.0')

sdk = dependency('expidus-sdk', native: false, required: false, include_type: 'system', method: 'pkg-config')
if sdk.found()
  uncrustify = find_program('uncrustify', sdk.get_variable('bindir'))
else
  uncrustify = disabler()
endif

conf_data = configuration_data()
conf_data.set('PREFIX', prefix)
conf_data.set('BINDIR', bindir)
conf_data.set('DATADIR', datadir)
conf_data.set('LIBDIR', libdir)
conf_data.set('LIBEXECDIR', libexecdir)
conf_data.set('VERSION', longver)
conf_data.set('BUILDDIR', meson.current_build_dir())
conf_data.set('SOURCEDIR', meson.current_source_dir())

build_conf_h = configure_file(input: 'src/build.h.in', output: 'build.h',
	configuration: conf_data)
build_conf = configure_file(input: 'src/build.vala.in', output: 'build.vala',
	configuration: conf_data)

rel_sources = ['src/application.vala', 'src/window.vala']
sources = []

foreach src : rel_sources
  sources += [join_paths(meson.current_source_dir(), src)]
endforeach

if uncrustify.found()
  run_target('prettier',
    command: [uncrustify, '--no-backup', sources])
endif

configure_file(input: 'data/expidus-terminal.desktop.in', output: 'expidus-terminal.desktop',
  configuration: conf_data,
  install: true,
  install_dir: join_paths(datadir, 'applications'))

executable('expidus-terminal', rel_sources,
  dependencies: [libtokyo, handy, vte],
  install: true)
