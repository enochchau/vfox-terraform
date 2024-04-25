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

	--- @type string | nil
	local sha256 = nil

	for line in string.gmatch(resp.body, "([^\n]*)\n?") do
		local hash, name = line:match("^(%w+)%s+(.+)$")
		if name == filename then
			sha256 = hash
			break
		end
	end

	if sha256 == nil then
		print("SHA256 Sum not found for `" .. filename .. "`. Continuing without checksum.")
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
