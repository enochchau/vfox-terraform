local http = require("http")
local util = {}

util.getInfo = function()
	local resp, err = http.get({
		url = "https://releases.hashicorp.com/terraform",
	})

	if err ~= nil then
		error("Failed to get information: " .. err)
	end
	if resp.status_code ~= 200 then
		error("Failed to get information: status_code =>" .. resp.status_code)
	end

	local output = {}

	for s in resp.body:gmatch("([^\n]*)\n?") do
		local i, j = string.find(s, "terraform_%d+.%d+.%d+%-?%a*%-?%d*")
		if i ~= nil then
			local version = string.sub(s, i, j)
			version = string.gsub(version, "terraform_", "")

			table.insert(output, {
				version = version,
			})
		end
	end

	return output
end

return util
