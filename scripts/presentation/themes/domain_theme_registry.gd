class_name DomainThemeRegistry
extends RefCounted

## Presentation-only registry. It knows visual identity and asset roots, never rules.

const THEMES := {
	"forest": {
		"title": "BOSQUE SALVAJE",
		"essence_label": "INSTINTO",
		"asset_root": "res://assets/domains/forest",
		"accent": "718744",
		"accent_secondary": "d3aa4d",
		"surface": "251a10",
		"danger": "873429"
	},
	"crypt": {
		"title": "CRIPTA DE HUESO",
		"essence_label": "RESTOS",
		"asset_root": "res://assets/domains/crypt",
		"accent": "76536f",
		"accent_secondary": "b95d4b",
		"surface": "171117",
		"danger": "8b2f35"
	},
	"tower": {
		"title": "TORRE ARCANA",
		"essence_label": "CONOCIMIENTO",
		"asset_root": "res://assets/domains/tower",
		"accent": "625c9b",
		"accent_secondary": "c4a75e",
		"surface": "141321",
		"danger": "7d405e"
	},
	"forge": {
		"title": "FUNDICIÓN ANTIGUA",
		"essence_label": "CALOR",
		"asset_root": "res://assets/domains/forge",
		"accent": "a65f32",
		"accent_secondary": "d79b43",
		"surface": "20130e",
		"danger": "9a3828"
	}
}

static func get_theme(domain: String) -> Dictionary:
	return Dictionary(THEMES.get(domain, THEMES["forest"])).duplicate(true)

static func asset_path(domain: String, relative_path: String) -> String:
	var theme := get_theme(domain)
	return str(theme.get("asset_root", "res://assets/domains/forest")).path_join(relative_path)
