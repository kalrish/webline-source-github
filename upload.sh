declare -r \
	bucket="${1?error: missing argument: S3 bucket}" \
	object_key="${2?error: missing argument: S3 object key}" \
	versions_file_path="${3?error: missing argument: version IDs file path}" \
	archive_file_path="${4?error: missing argument: versions archive file path}" \
	current_file_path="${5?error: missing argument: current file path}" \
	#


while read version_id
do
	temp_file_name="${version_id}.zip"

	if tar --extract --file "${archive_file_name}" "${temp_file_name}" | cmp --silent -- "${current_file_path}"
	then
		echo "${version_id}"

		exit 0
	fi
done < "${versions_file_path}"


version_id="$(
	aws \
		--query VersionId \
		--output text \
		s3api \
		put-object \
		--bucket "${bucket}" \
		--key "${object_key}" \
		"${current_file_path}" \
		#
)"

temp_file_name="${version_id}.zip"

cp \
	-n \
	-- \
	"${current_file_path}" \
	"${temp_file_name}" \
	#

tar \
	--append \
	--file "${archive_file_name}" \
	"${temp_file_name}" \
	#

rm \
	-f \
	-- \
	"${temp_file_name}" \
	#

echo "${version_id}"
