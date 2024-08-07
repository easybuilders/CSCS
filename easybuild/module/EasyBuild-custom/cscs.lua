help([[

Description
===========
Production EasyBuild @ CSCS

More information
================
 - Homepage: https://github.com/eth-cscs/production/wiki
]])

whatis([===[Description: Production EasyBuild @ CSCS  ]===])
whatis([===[Homepage: https://github.com/eth-cscs/production/wiki]===])
conflict("EasyBuild-custom")

-- system variables 
apps=os.getenv("APPS")
system=os.getenv("LMOD_SYSTEM_NAME") or os.getenv("CLUSTER_NAME")
common_dir=apps:gsub(system,'common')
-- EasyBuild-custom SETUP 
eb_config_dir=pathJoin(common_dir, "production/easybuild")
eb_module_dir=pathJoin(common_dir, "easybuild/modules/all/Core")
eb_root_dir=pathJoin(common_dir, "easybuild/software/EasyBuild-custom/cscs")
eb_runtime_dir=os.getenv("SCRATCH") or pathJoin("/tmp", os.getenv("USER"))
eb_source_dir=pathJoin(common_dir, "easybuild/sources")
setenv("EBROOTEASYBUILDMINCUSTOM", eb_root_dir)
setenv("EBVERSIONEASYBUILDMINCUSTOM", "cscs")
setenv("EBDEVELEASYBUILDMINCUSTOM", pathJoin(eb_root_dir, "/easybuild/EasyBuild-custom-cscs-easybuild-devel"))

--[[ 
 EB_CUSTOM_REPOSITORY defines the following variables:
 * XDG_CONFIG_DIRS
 * EASYBUILD_ROBOT_PATHS
 * EASYBUILD_INCLUDE_EASYBLOCKS
 * EASYBUILD_INCLUDE_MODULE_NAMING_SCHEMES
 * EASYBUILD_INCLUDE_TOOLCHAINS
 * EASYBUILD_EXTERNAL_MODULES_METADATA (see section SYSTEM SPECIFIC)
--]]
eb_custom_repository=os.getenv("EB_CUSTOM_REPOSITORY") or eb_config_dir
setenv("XDG_CONFIG_DIRS", eb_custom_repository)
setenv("EASYBUILD_ROBOT_PATHS", pathJoin(eb_custom_repository, "easyconfigs/:"))
setenv("EASYBUILD_INCLUDE_EASYBLOCKS", pathJoin(eb_custom_repository, "easyblocks/*.py"))
setenv("EASYBUILD_INCLUDE_MODULE_NAMING_SCHEMES", pathJoin(eb_custom_repository, "tools/module_naming_scheme/*.py"))
setenv("EASYBUILD_INCLUDE_TOOLCHAINS", pathJoin(eb_custom_repository, "toolchains/*.py,", eb_custom_repository, "toolchains/compiler/*.py"))

--[[ 
 XDG_RUNTIME_DIR defines the following variables:
 * EASYBUILD_BUILDPATH
 * EASYBUILD_TMPDIR
--]]
xdg_runtime_dir=os.getenv("XDG_RUNTIME_DIR") or eb_runtime_dir
if not os.getenv("EASYBUILD_BUILDPATH") then
	setenv("EASYBUILD_BUILDPATH", pathJoin(xdg_runtime_dir, "build"))
end
if not os.getenv("EASYBUILD_TMPDIR") then
	setenv("EASYBUILD_TMPDIR", pathJoin(xdg_runtime_dir, "tmp"))
end

-- EASYBUILD_SOURCEPATH: use eb_source_dir if writable, otherwise $HOME/sources
if not os.getenv("EASYBUILD_SOURCEPATH") then
	if subprocess("test -w " .. eb_source_dir .. " ; echo $?") < "1" then
		setenv("EASYBUILD_SOURCEPATH", eb_source_dir)
	else
		setenv("EASYBUILD_SOURCEPATH", pathJoin(os.getenv("HOME"), "sources"))
	end
end

-- SYSTEM SPECIFIC (Cray with Lmod)
if system == "eiger" then
	setenv("EASYBUILD_EXTERNAL_MODULES_METADATA", pathJoin(eb_custom_repository, "cpe_external_modules_metadata-23.12.cfg"))
elseif system == "pilatus" then
	setenv("EASYBUILD_EXTERNAL_MODULES_METADATA", pathJoin(eb_custom_repository, "cpe_external_modules_metadata-23.12.cfg"))
elseif system == "rigi" then
	setenv("EASYBUILD_EXTERNAL_MODULES_METADATA", pathJoin(eb_custom_repository, "cpe_external_modules_metadata-23.12.cfg"))
else
	LmodError("System ", system, " is currently unsupported\n")
end
setenv("EASYBUILD_MODULE_NAMING_SCHEME", "HierarchicalMNS")
setenv("EASYBUILD_MODULE_SYNTAX", "Lua")
setenv("EASYBUILD_MODULES_TOOL", "Lmod")
setenv("EASYBUILD_OPTARCH", os.getenv("CRAY_CPU_TARGET"))
setenv("EASYBUILD_RECURSIVE_MODULE_UNLOAD", "0")

-- EASYBUILD_INSTALLPATH
if not os.getenv("EASYBUILD_INSTALLPATH") then
        eb_installpath=os.getenv("EASYBUILD_PREFIX") or pathJoin(os.getenv("HOME"), "easybuild", system)
        setenv("EASYBUILD_INSTALLPATH", eb_installpath)
end
-- EASYBUILD_PREFIX
if not os.getenv("EASYBUILD_PREFIX") then
	setenv("EASYBUILD_PREFIX", pathJoin(os.getenv("HOME"), "easybuild", system))
end

-- add EasyBuild module folder to MODULEPATH and load EasyBuild
prepend_path("MODULEPATH", eb_module_dir)
load("EasyBuild")
