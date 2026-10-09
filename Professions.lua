-- Independent profession shortcuts for the original TBC 2.4.3 API.
local CS = ClassSphere
local P = { buttons = {}, active = {} }
CS.professions = P
local defs = {
    { id="alchemy", spell=2259 },
    { id="blacksmith", spell=2018 },
    { id="enchant", spell=7411, right=13262 },
    { id="engineer", spell=4036 },
    { id="herbs", spell=2366, left=2383, tracking=true },
    { id="jewel", spell=25229, right=31252 },
    { id="leather", spell=2108 },
    { id="mining", spell=2575, left=2656, right=2580, tracking=true },
    { id="skinning", spell=8613 },
    { id="tailor", spell=3908 },
    { id="cooking", spell=2550, right=818 },
    { id="firstaid", spell=3273 },
    { id="fishing", spell=7620, right=43308, trackingRight=true },
}
local function Combat() return InCombatLockdown and InCombatLockdown() end
local function Learned(id)
    local name = id and GetSpellInfo(id)
    return name and CS.spellbook[name] or nil
end
local function KnownProfession(id)
    local learned=Learned(id)
    if learned then return learned end
    -- Gathering skills may be listed only in the skill window, not the spellbook.
    local name=GetSpellInfo(id)
    for i=1,GetNumSkillLines() do
        local skill,header,_,rank=GetSkillLineInfo(i)
        if not header and skill==name and rank and rank>0 then return {name=name} end
    end
end
local function Init()
    local c = CS:GetCharDB()
    c.professions = c.professions or {}
    P.db = c.professions
    local defaults = { enabled=true, expanded=false, always=false, locked=false, scale=1, buttonScale=1, x=240, y=0, hidden={} }
    for k,v in pairs(defaults) do if P.db[k]==nil then P.db[k]=v end end
end
local function Tooltip(b)
    GameTooltip:SetOwner(b, "ANCHOR_RIGHT")
    GameTooltip:SetText(b.profName)
    for i=1,GetNumSkillLines() do
        local name, header, _, rank, _, _, maximum = GetSkillLineInfo(i)
        if not header and name==b.profName then
            GameTooltip:AddLine(tostring(rank).." / "..tostring(maximum), 1,1,1)
            break
        end
    end
    if b.left then GameTooltip:AddLine("Clic gauche : "..b.left.name, 1,1,1) end
    if b.right then GameTooltip:AddLine("Clic droit : "..b.right.name, 1,1,1) end
    GameTooltip:Show()
end
function P:Visibility()
    if Combat() then self.pending=true; return end
    local show = self.db.enabled and (self.db.expanded or self.db.always)
    if self.db.enabled then self.sphere:Show() else self.sphere:Hide() end
    for _,b in pairs(self.buttons) do b:Hide() end
    if show then for _,b in ipairs(self.active) do b:Show() end end
end
function P:EnsureSphere()
    if self.sphere then return end
    local f=CreateFrame("Button", "ClassSphereProfessionsMain", UIParent)
    self.sphere=f
    f:SetWidth(56); f:SetHeight(56); f:EnableMouse(true); f:SetMovable(true)
    f:SetClampedToScreen(true); f:RegisterForDrag("LeftButton")
    f:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    f.icon=f:CreateTexture(nil,"BACKGROUND"); f.icon:SetAllPoints(f)
    f.icon:SetTexture("Interface\\Icons\\Trade_Engineering")
    f.icon:SetTexCoord(.07,.93,.07,.93)
    f:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    f:SetScript("OnDragStart",function()
        if IsShiftKeyDown() and not P.db.locked and not Combat() then
            this.csDragging=true
            this:StartMoving()
        end
    end)
    f:SetScript("OnDragStop",function()
        if not this.csDragging then return end
        this:StopMovingOrSizing()
        this.csDragging=false
        local point,_,relative,x,y=this:GetPoint(1)
        P.db.point=point; P.db.relative=relative; P.db.x=x; P.db.y=y
    end)
    f:SetScript("OnClick",function()
        if arg1=="RightButton" then P:ToggleConfig(); return end
        if IsShiftKeyDown() then return end
        if Combat() then CS:Print("Les métiers peuvent être affichés ou masqués hors combat."); return end
        P.db.expanded=not P.db.expanded; P:Visibility()
    end)
    f:SetScript("OnEnter",function()
        GameTooltip:SetOwner(this,"ANCHOR_RIGHT"); GameTooltip:SetText("ClassSphere : métiers")
        GameTooltip:AddLine("Clic gauche : afficher / masquer",1,1,1)
        GameTooltip:AddLine("Clic droit : options métiers",1,1,1)
        GameTooltip:AddLine("Maj + glisser : déplacer",1,1,1); GameTooltip:Show()
    end)
    f:SetScript("OnLeave",function() GameTooltip:Hide() end)
    f:SetPoint(self.db.point or "CENTER",UIParent,self.db.relative or "CENTER",self.db.x,self.db.y)
end
function P:Refresh()
    if not CS.db then return end
    if Combat() then self.pending=true; return end
    Init(); self.pending=false
    CS:BuildSpellBook(); self:EnsureSphere()
    self.sphere:SetScale(self.db.scale)
    self.active={}
    for _,d in ipairs(defs) do
        local profession=KnownProfession(d.spell)
        if profession and not self.db.hidden[d.id] then
            local b=self.buttons[d.id]
            if not b then
                b=CreateFrame("Button","ClassSphereProfession_"..d.id,UIParent,"SecureActionButtonTemplate")
                CS:ApplySquareButtonSkin(b,false)
                b:RegisterForClicks("LeftButtonUp","RightButtonUp")
                b:SetScript("OnEnter",function() Tooltip(this) end)
                b:SetScript("OnLeave",function() GameTooltip:Hide() end)
                self.buttons[d.id]=b
            end
            b.profName=profession.name; b.left=Learned(d.left or d.spell); b.right=Learned(d.right)
            for click=1,2 do
                local s=click==1 and b.left or b.right
                b:SetAttribute("type"..click,s and "spell" or nil)
                b:SetAttribute("spell"..click,s and s.name or nil)
            end
            local s=b.left or profession
            b.icon:SetTexture(s.slot and GetSpellTexture(s.slot,BOOKTYPE_SPELL) or "Interface\\Icons\\INV_Misc_QuestionMark")
            b:SetScale(self.db.buttonScale)
            table.insert(self.active,b)
        end
    end
    -- Two rows above and below the central icon, at most seven per row.
    local n=table.getn(self.active); local top=math.ceil(n/2)
    for i,b in ipairs(self.active) do
        local upper=i<=top; local j=upper and i or i-top
        local count=upper and top or n-top
        local gap=36*self.db.buttonScale
        b:ClearAllPoints()
        -- Offsets are in the button's coordinate system, keeping the spacing stable.
        b:SetPoint("CENTER",self.sphere,"CENTER",((j-1)-(count-1)/2)*gap/self.db.buttonScale,(upper and 62 or -62)*self.db.scale/self.db.buttonScale)
    end
    self:Visibility(); self:UpdateTracking()
end
function P:UpdateTracking()
    for _,d in ipairs(defs) do
        local b=self.buttons[d.id]
        if b and b:IsVisible() then
            local s=d.tracking and b.left or (d.trackingRight and b.right)
            local active=false
            if s and GetTrackingTexture then active=GetTrackingTexture()==GetSpellTexture(s.slot,BOOKTYPE_SPELL) end
            if active then b.icon:SetVertexColor(.45,1,.45) else b.icon:SetVertexColor(1,1,1) end
        end
    end
end
local function Check(f,text,y,read,write)
    local b=CreateFrame("CheckButton",nil,f,"UICheckButtonTemplate")
    b:SetPoint("TOPLEFT",f,"TOPLEFT",20,y)
    local t=b:CreateFontString(nil,"OVERLAY","GameFontNormal"); t:SetPoint("LEFT",b,"RIGHT",2,0); t:SetText(text)
    b.read=read
    b:SetScript("OnClick",function() write(this:GetChecked() and true or false); P:Refresh() end)
    table.insert(f.checks,b)
end
function P:ToggleConfig()
    if not self.db then Init() end
    if not self.config then
        local f=CreateFrame("Frame","ClassSphereProfessionsConfig",UIParent)
        self.config=f; f.checks={}; f:SetWidth(380); f:SetHeight(620)
        f:SetPoint("CENTER",UIParent,"CENTER",0,0); f:SetFrameStrata("DIALOG"); f:EnableMouse(true)
        f:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile=true,tileSize=32,edgeSize=32,insets={left=11,right=12,top=12,bottom=11}})
        local title=f:CreateFontString(nil,"OVERLAY","GameFontHighlightLarge"); title:SetPoint("TOP",f,"TOP",0,-20); title:SetText("ClassSphere : métiers")
        Check(f,"Afficher la sphère métiers",-48,function() return P.db.enabled end,function(v) P.db.enabled=v end)
        Check(f,"Toujours afficher les boutons",-78,function() return P.db.always end,function(v) P.db.always=v end)
        Check(f,"Verrouiller la position",-108,function() return P.db.locked end,function(v) P.db.locked=v end)
        for i,d in ipairs(defs) do
            local id=d.id; local name=GetSpellInfo(d.spell) or id
            Check(f,name,-140-(i-1)*27,function() return not P.db.hidden[id] end,function(v) P.db.hidden[id]=not v end)
        end
        local label=f:CreateFontString(nil,"OVERLAY","GameFontNormal"); label:SetPoint("TOPLEFT",f,"TOPLEFT",26,-504); label:SetText("Taille sphère / boutons")
        for i,key in ipairs({"scale","buttonScale"}) do
            local k=key; local name="ClassSphereProfessionsScale"..i
            local s=CreateFrame("Slider",name,f,"OptionsSliderTemplate")
            s:SetPoint("TOPLEFT",f,"TOPLEFT",26+(i-1)*170,-535); s:SetWidth(145); s:SetMinMaxValues(60,150); s:SetValueStep(5)
            getglobal(name.."Low"):SetText("60%"); getglobal(name.."High"):SetText("150%")
            getglobal(name.."Text"):SetText(i==1 and "Sphère" or "Boutons")
            s:SetScript("OnValueChanged",function() if f.updating then return end P.db[k]=this:GetValue()/100; P:Refresh() end)
            f[k]=s
        end
        local close=CreateFrame("Button",nil,f,"UIPanelButtonTemplate"); close:SetWidth(100); close:SetHeight(22); close:SetText("Fermer"); close:SetPoint("BOTTOM",f,"BOTTOM",0,18); close:SetScript("OnClick",function() f:Hide() end)
        f:Hide()
    end
    local f=self.config
    if f:IsVisible() then f:Hide(); return end
    f.updating=true
    for _,b in ipairs(f.checks) do b:SetChecked(b.read()) end
    f.scale:SetValue(self.db.scale*100); f.buttonScale:SetValue(self.db.buttonScale*100)
    f.updating=false; f:Show()
end
local events=CreateFrame("Frame")
for _,e in ipairs({"PLAYER_LOGIN","SPELLS_CHANGED","SKILL_LINES_CHANGED","PLAYER_REGEN_ENABLED","MINIMAP_UPDATE_TRACKING"}) do events:RegisterEvent(e) end
events:SetScript("OnEvent",function()
    if event=="MINIMAP_UPDATE_TRACKING" then P:UpdateTracking()
    elseif event=="PLAYER_REGEN_ENABLED" then if P.pending then P:Refresh() end
    else P:Refresh() end
end)
SLASH_CLASSSPHEREPROFESSIONS1="/csp"
SlashCmdList["CLASSSPHEREPROFESSIONS"]=function() P:ToggleConfig() end
