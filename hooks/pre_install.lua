local http = require("http")

--- Returns some pre-installed information, such as version number, download address, local files, etc.
--- If checksum is provided, vfox will automatically check it for you.
--- @param ctx table
--- @field ctx.version string User-input version
--- @return table Version information
function PLUGIN:PreInstall(ctx)
	local version = ctx.version

	local archType = RUNTIME.archType
	local osType = RUNTIME.osType

	local baseURL = "https://releases.hashicorp.com/terraform/" .. version .. "/"

	local filename = "terraform_" .. version .. "_" .. osType .. "_" .. archType .. ".zip"
	local url = baseURL .. filename

	local resp, err = http.get({ url = baseURL .. "terraform_" .. version .. "_SHA256SUMS" })

	if err ~= nil or resp.status_code ~= 200 then
		error("get checksum failed")
	end

	print("filename", filename)

	local sha256

	local lines = {}
	for word in string.gmatch(resp.body, "%S+") do
		table.insert(lines, word)
	end

	for i = 1, #lines, 2 do
		local hash = lines[i]
		local name = lines[i + 1]
		if name == filename then
			sha256 = hash
			break
		end
	end

	return {
		--- Version number
		version = version,
		--- remote URL or local file path [optional]
		url = url,
		--- SHA256 checksum [optional]
		sha256 = sha256,
	}
end
