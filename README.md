# Mika UI

> make interfaces with Mika ui

**Mika UI** é uma library de interface para Roblox e executores, em arquivo único, no estilo Rayfield / WindUI — mas com identidade visual própria: vidro escuro, gradientes aurora, traços suaves e micro animações.

![version](https://img.shields.io/badge/version-1.0.0-blueviolet) ![license](https://img.shields.io/badge/license-MIT-green)

---

## Instalação

```lua
local MikaUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/vexzinho0/Mika-UI/main/MikaUI.lua"))()

local Window = MikaUI:CreateWindow({
    Title = "Mika UI",
    Subtitle = "make interfaces with Mika ui",
})

local Tab = Window:CreateTab("Main")
local Sec = Tab:CreateSection("General")

Sec:CreateButton({
    Name = "Click me",
    Callback = function()
        MikaUI:Notify({ Title = "Mika UI", Content = "Olá!" })
    end,
})
```

Não precisa de dependências, módulos externos ou assets remotos. Um arquivo, um `loadstring`.

---

## Elementos

Todos ficam dentro de uma seção (`Tab:CreateSection`).

| Elemento | Chamada | Retorno |
|---|---|---|
| Botão | `Sec:CreateButton{ Name, Description, Callback }` | `Instance` |
| Toggle | `Sec:CreateToggle{ Name, Default, Callback }` | `:Set(v)` `:Get()` |
| Slider | `Sec:CreateSlider{ Name, Min, Max, Default, Step, Suffix, Callback }` | `:Set(v)` `:Get()` |
| Dropdown | `Sec:CreateDropdown{ Name, Options, Default, Multi, Callback }` | `:Set(v)` `:Get()` |
| Input | `Sec:CreateInput{ Name, Placeholder, Default, Callback }` | `:Set(v)` `:Get()` |
| Keybind | `Sec:CreateKeybind{ Name, Default, Callback }` | `:Set(key)` `:Get()` |
| Color picker | `Sec:CreateColorPicker{ Name, Default, Callback }` | `:Set(color)` `:Get()` |
| Texto | `Sec:CreateLabel{ Name, Text }` | `:Set(text)` |
| Parágrafo | `Sec:CreateParagraph{ Text }` | `:Set(text)` |
| Divisor | `Sec:CreateDivider()` | — |
| Link | `Sec:CreateLinkButton{ Name, Url }` | — |
| **Conteúdo externo** | `Sec:CreateExternalView{ Name, Url, Height, AutoLoad }` | `:Refresh()` `:SetUrl(url)` |

Exemplo:

```lua
local toggle = Sec:CreateToggle({ Name = "ESP", Default = true, Callback = print })
toggle:Set(false)
print(toggle:Get())
```

---

## Links externos dentro da interface

O `CreateExternalView` busca uma URL e renderiza o conteúdo **dentro do hub**, num painel rolável com botões `reload` e `open`. HTML é convertido em texto limpo automaticamente, então serve tanto para páginas quanto para arquivos `.txt`, `.md` ou JSON cru.

```lua
local view = Sec:CreateExternalView({
    Name = "Notícias",
    Url = "https://example.com",
    Height = 200,
})

view:SetUrl("https://raw.githubusercontent.com/user/repo/main/changelog.md")
view:Refresh()
```

Também é possível buscar conteúdo direto para usar em qualquer lugar:

```lua
local texto = MikaUI:Fetch("https://example.com")
```

E carregar um **tema** hospedado na web (JSON):

```json
{
  "Accent": "#7aa4ff",
  "Accent2": "#be8aff",
  "Background": [14, 16, 24],
  "Surface": [26, 29, 42],
  "Text": "238, 242, 255",
  "SubText": "148, 157, 189"
}
```

```lua
MikaUI:LoadThemeFromURL("https://exemplo.com/mika-theme.json")
```

---

## Temas

Prontos: `Aurora`, `Midnight`, `Sakura`, `Neon`, `Mono`, `Void`, `Daylight`.

```lua
MikaUI:SetTheme("Sakura")
MikaUI:ListThemes()
```

Tema próprio (aplicado na hora, em todas as janelas abertas):

```lua
MikaUI:SetTheme({
    Accent = Color3.fromRGB(255, 145, 190),
    Background = { 20, 16, 24 },
    Text = "#ffedf5",
})
```

---

## Customização

| Função | O que faz |
|---|---|
| `MikaUI:SetTheme(nome ou tabela)` | Troca o tema em tempo real |
| `MikaUI:SetAccent(color)` | Cor de destaque |
| `MikaUI:SetAccentGradient(a, b)` | Gradiente de destaque |
| `MikaUI:SetFont(Enum.Font)` | Fonte dos textos |
| `MikaUI:SetTitleFont(Enum.Font)` | Fonte dos títulos |
| `MikaUI:SetCornerRadius(px)` | Arredondamento global |
| `MikaUI:SetTransparency({ window = 0.05, element = 0.4 })` | Transparência |
| `MikaUI:SetAnimations(bool)` / `SetAnimationSpeed(s)` | Animações |
| `MikaUI:SetBlur(bool)` | Blur de fundo (BlurEffect) |
| `MikaUI:SetWatermark({ Text, Transparency, TextSize, Visible })` | Marca d'água |
| `MikaUI:Notify({ Title, Content, Duration, Accent })` | Notificação |
| `MikaUI:OpenLink(url)` | Copia/abre o link |
| `MikaUI:Fetch(url)` | Baixa e limpa o conteúdo |
| `MikaUI:LoadThemeFromURL(url)` | Tema vindo da web |
| `MikaUI:GetTheme()` / `ListThemes()` / `GetConfig()` | Leitura |

Na janela: `Window:CreateTab(nome, icone)`, `Window:SelectTab(tab)`, `Window:SetTitle/SetSubtitle`, `Window:Minimize()`, `Window:Toggle()`, `Window:Destroy()`.

Opções do `CreateWindow`: `Title`, `Subtitle`, `Icon` (asset id), `Size`, `Position`, `Theme`, `ToggleKey`, `SidebarWidth`, `DisplayOrder`, `TopBar`.

---

## Marca d'água

Canto inferior direito, 10px, transparência 0.86 — "make interfaces with Mika ui".

```lua
MikaUI:SetWatermark({ Transparency = 0.9 })   -- ainda mais discreta
MikaUI:SetWatermark({ Visible = false })      -- remove
MikaUI:SetWatermark({ Text = "seu texto" })   -- troca
```

---

## Compatibilidade

- Funciona em qualquer executor com `loadstring` + `game:HttpGet` (Synapse, Fluxus, Wave, Delta, AWP, Solara…).
- Usa `syn.request` / `fluxus.request` / `http_request` / `request` quando existem, com fallback para `game:HttpGet`.
- `gethui` / `protect_gui` são usados quando disponíveis (GUI mais protegida).
- Também roda no Roblox Studio, dentro de `PlayerGui`.

---

## Licença

MIT — use, modifique e redistribua.
