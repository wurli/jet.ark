-- Prepend BASE_URL to relative URLs in links and images.
-- Usage: pandoc --lua-filter prefix-relative-urls.lua -M base-url=http://127.0.0.1:50925

local function resolve_dots(url)
	local scheme, path, query = url:match("^(https?://)([^%?]*)(%??.*)$")
	if not scheme then
		return url
	end
	local parts = {}
	for seg in path:gmatch("[^/]+") do
		if seg == ".." then
			parts[#parts] = nil
		elseif seg ~= "." then
			parts[#parts + 1] = seg
		end
	end
	return scheme .. table.concat(parts, "/") .. query
end

local function prefix(url, base_url)
	if base_url == "" then
		return url
	end
	if url:match("^https?://") or url:match("^#") or url:match("^mailto:") then
		return url
	end
	return resolve_dots(base_url .. url)
end

function Pandoc(doc)
	local base_url = doc.meta["base-url"] and pandoc.utils.stringify(doc.meta["base-url"]) or ""
	if base_url ~= "" and not base_url:match("/$") then
		base_url = base_url .. "/"
	end

	return doc:walk({
		Link = function(el)
			el.target = prefix(el.target, base_url)
			return el
		end,
		Image = function(el)
			el.src = prefix(el.src, base_url)
			return el
		end,
	})
end
