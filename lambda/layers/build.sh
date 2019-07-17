(
	set -e

	export \
		BUNDLE_CACHE_PATH=../../../.gems \
		#

	bundle \
		install \
		--no-color \
		--quiet \
		--local \
		--path pkg \
		#

	cd pkg

	zip \
		-q \
		-X \
		-9 \
		-r \
		../pkg.zip \
		-- \
		. \
		#
)

rm \
	-f \
	-r \
	-- \
	.bundle \
	Gemfile.lock \
	pkg \
	#
