resource "azurerm_cdn_frontdoor_profile" "main" {
  name                = "afd-landingpage"
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "Standard_AzureFrontDoor"
}

resource "azurerm_cdn_frontdoor_origin_group" "main" {
  name                     = "landingpage-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  session_affinity_enabled = true

  load_balancing {
    additional_latency_in_milliseconds = 0
    sample_size                        = 16
    successful_samples_required        = 3
  }
}

resource "azurerm_cdn_frontdoor_origin" "main" {
  name                          = "landingpage-origin"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main.id
  enabled                       = true

  certificate_name_check_enabled = false

  host_name          = "landing.dean-fw.uk"
  http_port          = 80
  https_port         = 443
  origin_host_header = "landing.dean-fw.uk"
  priority           = 1
  weight             = 1
}

resource "azurerm_cdn_frontdoor_endpoint" "main" {
  name                     = "landingpage-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
}

resource "azurerm_cdn_frontdoor_rule_set" "main" {
  name                     = "landingpageruleset"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
}

resource "azurerm_cdn_frontdoor_route" "main" {
  name                          = "landingpage-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.main.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.main.id]
  cdn_frontdoor_rule_set_ids    = [azurerm_cdn_frontdoor_rule_set.main.id]
  enabled                       = true

  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true
  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]

  cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.main.id]
  link_to_default_domain          = false
}

resource "azurerm_cdn_frontdoor_custom_domain" "main" {
  name                     = "landing-page"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  host_name                = "landing.dean-fw.uk"

  tls {
    certificate_type = "ManagedCertificate"
  }
}

resource "azurerm_cdn_frontdoor_custom_domain_association" "main" {
  cdn_frontdoor_custom_domain_id = azurerm_cdn_frontdoor_custom_domain.main.id
  cdn_frontdoor_route_ids        = [azurerm_cdn_frontdoor_route.main.id]
}
