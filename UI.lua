local CS = ClassSphere

local function MakeButton(parent, text, width, height)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetWidth(width or 100); b:SetHeight(height or 22); b:SetText(text or "")
    return b
end

local function MakeCheck(parent, text)
    local c = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    c.text = c:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    c.text:SetPoint("LEFT", c, "RIGHT", 2, 1); c.text:SetText(text or "")
    return c
end

local function MakeSlider(name, parent, minv, maxv, step, width)
    local s = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    s:SetMinMaxValues(minv,maxv); s:SetValueStep(step); s:SetWidth(width or 180); s:SetHeight(16)
    getglobal(name.."Low"):SetText(tostring(minv)); getglobal(name.."High"):SetText(tostring(maxv)); getglobal(name.."Text"):SetText("")
    return s
end

function CS:EnsureConfig()
    if self.configFrame then return end
    local f = CreateFrame("Frame", "ClassSphereConfig", UIParent)
    f:SetWidth(520); f:SetHeight(760); f:SetPoint("CENTER",UIParent,"CENTER",0,0)
    f:SetFrameStrata("DIALOG"); f:EnableMouse(true); f:SetMovable(true); f:RegisterForDrag("LeftButton")
    f:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile=true,tileSize=32,edgeSize=32,insets={left=11,right=12,top=12,bottom=11}})
    f:SetScript("OnDragStart",function() this:StartMoving() end); f:SetScript("OnDragStop",function() this:StopMovingOrSizing() end)
    f.title=f:CreateFontString(nil,"OVERLAY","GameFontHighlightLarge"); f.title:SetPoint("TOP",f,"TOP",0,-16); f.title:SetText("ClassSphere 2.4.3")
    local close=MakeButton(f,"Fermer",80,22); close:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-18,18); close:SetScript("OnClick",function() f:Hide() end)

    local lock=MakeCheck(f,"Verrouiller la sphère"); lock:SetPoint("TOPLEFT",f,"TOPLEFT",24,-52); lock:SetScript("OnClick",function() CS.db.locked=this:GetChecked() and true or false end); f.lock=lock
    local visible=MakeCheck(f,"Afficher la sphère"); visible:SetPoint("TOPLEFT",f,"TOPLEFT",245,-52); visible:SetScript("OnClick",function() CS.db.visible=this:GetChecked() and true or false; CS:QueueRefresh() end); f.visible=visible

    local scaleLabel=f:CreateFontString(nil,"OVERLAY","GameFontNormal"); scaleLabel:SetPoint("TOPLEFT",f,"TOPLEFT",24,-92); scaleLabel:SetText("Taille sphère")
    local scale=MakeSlider("ClassSphereScaleSlider",f,50,150,5,175); scale:SetPoint("TOPLEFT",f,"TOPLEFT",24,-114); scale:SetScript("OnValueChanged",function() if not CS.db then return end CS.db.scale=this:GetValue()/100; if CS.sphere then CS.sphere:SetScale(CS.db.scale) end end); f.scaleSlider=scale
    local bscaleLabel=f:CreateFontString(nil,"OVERLAY","GameFontNormal"); bscaleLabel:SetPoint("TOPLEFT",f,"TOPLEFT",275,-92); bscaleLabel:SetText("Taille boutons")
    local bscale=MakeSlider("ClassSphereButtonScaleSlider",f,60,160,5,175); bscale:SetPoint("TOPLEFT",f,"TOPLEFT",275,-114); bscale:SetScript("OnValueChanged",function() if not CS.db then return end CS.db.buttonScale=this:GetValue()/100; CS:QueueRefresh() end); f.buttonScaleSlider=bscale
    local radiusLabel=f:CreateFontString(nil,"OVERLAY","GameFontNormal"); radiusLabel:SetPoint("TOPLEFT",f,"TOPLEFT",24,-158); radiusLabel:SetText("Distance des boutons")
    local radius=MakeSlider("ClassSphereRadiusSlider",f,50,160,2,175); radius:SetPoint("TOPLEFT",f,"TOPLEFT",24,-180); radius:SetScript("OnValueChanged",function() if not CS.db then return end CS.db.radius=this:GetValue(); CS:QueueRefresh() end); f.radiusSlider=radius
    local angleLabel=f:CreateFontString(nil,"OVERLAY","GameFontNormal"); angleLabel:SetPoint("TOPLEFT",f,"TOPLEFT",275,-158); angleLabel:SetText("Angle de départ")
    local angle=MakeSlider("ClassSphereAngleSlider",f,0,355,5,175); angle:SetPoint("TOPLEFT",f,"TOPLEFT",275,-180); angle:SetScript("OnValueChanged",function() if not CS.db then return end CS.db.angle=this:GetValue(); CS:QueueRefresh() end); f.angleSlider=angle

    local menuDelayLabel=f:CreateFontString(nil,"OVERLAY","GameFontNormal"); menuDelayLabel:SetPoint("TOPLEFT",f,"TOPLEFT",24,-210); menuDelayLabel:SetText("Fermeture auto des menus"); f.menuDelayLabel=menuDelayLabel
    local menuDelay=MakeSlider("ClassSphereMenuDelaySlider",f,0,15,1,175); menuDelay:SetPoint("TOPLEFT",f,"TOPLEFT",24,-230)
    menuDelay:SetScript("OnValueChanged",function()
        if not CS.db then return end
        local value=math.floor(this:GetValue()+0.5)
        CS.db.menuAutoCloseDelay=value
        if value<=0 then CS.configFrame.menuDelayLabel:SetText("Fermeture auto des menus : désactivée") else CS.configFrame.menuDelayLabel:SetText("Fermeture auto des menus : "..value.." s") end
        for _,menu in pairs(CS.menus) do menu.csIdleTime=0 end
    end)
    f.menuDelaySlider=menuDelay
    local menuDelayHint=f:CreateFontString(nil,"OVERLAY","GameFontNormalSmall"); menuDelayHint:SetPoint("LEFT",menuDelay,"RIGHT",25,0); menuDelayHint:SetText("0 = désactivé")

    local sep=f:CreateTexture(nil,"ARTWORK") sep:SetTexture("Interface\\Common\\UI-TooltipDivider-Transparent") sep:SetHeight(8) sep:SetPoint("TOPLEFT",f,"TOPLEFT",18,-258) sep:SetPoint("TOPRIGHT",f,"TOPRIGHT",-18,-258)
    local bl=f:CreateFontString(nil,"OVERLAY","GameFontHighlight") bl:SetPoint("TOPLEFT",f,"TOPLEFT",24,-276) bl:SetText("Boutons visibles / ordre")

    f.rows={}
    local i
    for i=1,9 do
        local row=CreateFrame("Frame",nil,f); row:SetWidth(450); row:SetHeight(25); row:SetPoint("TOPLEFT",f,"TOPLEFT",24,-296-(i-1)*27)
        row.check=MakeCheck(row,""); row.check:SetPoint("LEFT",row,"LEFT",0,0)
        row.up=MakeButton(row,"+",26,20); row.up:SetPoint("RIGHT",row,"RIGHT",-32,0)
        row.down=MakeButton(row,"-",26,20); row.down:SetPoint("RIGHT",row,"RIGHT",0,0)
        f.rows[i]=row
    end

    f.classPanel=CreateFrame("Frame",nil,f); f.classPanel:SetWidth(465); f.classPanel:SetHeight(160); f.classPanel:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",24,52)
    self.configFrame=f
end

function CS:MoveOrder(id, delta)
    local idx=nil; local i
    for i=1,table.getn(self.char.order) do if self.char.order[i]==id then idx=i break end end
    if not idx then return end
    local ni=idx+delta
    if ni<1 or ni>table.getn(self.char.order) then return end
    self.char.order[idx],self.char.order[ni]=self.char.order[ni],self.char.order[idx]
    self:QueueRefresh(); self:RefreshConfig()
end

local function ClearPanel(p)
    if p.dynamic then for _,o in pairs(p.dynamic) do o:Hide() end end
    p.dynamic={}
end

local function AddDyn(p,o) table.insert(p.dynamic,o); return o end

function CS:BuildShamanConfig(p)
    local s=self.char.shaman; s.setCount=tonumber(s.setCount) or 3; s.activeSet=tonumber(s.activeSet) or 1; s.sets=s.sets or {}
    local i
    for i=1,s.setCount do s.sets[i]=s.sets[i] or {name="Set "..i,EARTH="NONE",FIRE="NONE",WATER="NONE",AIR="NONE"} end
    local title=AddDyn(p,p:CreateFontString(nil,"OVERLAY","GameFontHighlight")); title:SetPoint("TOPLEFT",p,"TOPLEFT",0,0); title:SetText("Sets de totems")
    local minus=AddDyn(p,MakeButton(p,"-",28,20)); minus:SetPoint("TOPLEFT",p,"TOPLEFT",125,3)
    local count=AddDyn(p,p:CreateFontString(nil,"OVERLAY","GameFontNormal")); count:SetPoint("LEFT",minus,"RIGHT",8,0); count:SetText(tostring(s.setCount))
    local plus=AddDyn(p,MakeButton(p,"+",28,20)); plus:SetPoint("LEFT",count,"RIGHT",8,0)
    minus:SetScript("OnClick",function() if s.setCount>1 then s.setCount=s.setCount-1; if s.activeSet>s.setCount then s.activeSet=s.setCount end; CS:QueueRefresh(); CS:RefreshConfig() end end)
    plus:SetScript("OnClick",function() if s.setCount<10 then s.setCount=s.setCount+1; s.sets[s.setCount]=s.sets[s.setCount] or {name="Set "..s.setCount,EARTH="NONE",FIRE="NONE",WATER="NONE",AIR="NONE"}; CS:RefreshConfig() end end)
    local prev=AddDyn(p,MakeButton(p,"<",28,20)); prev:SetPoint("TOPLEFT",p,"TOPLEFT",245,3)
    local active=AddDyn(p,p:CreateFontString(nil,"OVERLAY","GameFontNormal")); active:SetPoint("LEFT",prev,"RIGHT",8,0); active:SetText("Set "..s.activeSet)
    local nextb=AddDyn(p,MakeButton(p,">",28,20)); nextb:SetPoint("LEFT",active,"RIGHT",8,0)
    prev:SetScript("OnClick",function() s.activeSet=s.activeSet-1; if s.activeSet<1 then s.activeSet=s.setCount end; CS:QueueRefresh(); CS:RefreshConfig() end)
    nextb:SetScript("OnClick",function() s.activeSet=s.activeSet+1; if s.activeSet>s.setCount then s.activeSet=1 end; CS:QueueRefresh(); CS:RefreshConfig() end)
    local set=s.sets[s.activeSet]
    local elements={{"EARTH","Terre"},{"FIRE","Feu"},{"WATER","Eau"},{"AIR","Air"}}
    local function Cycle(element)
        local list={CS.EmptyChoice}; local n; for n=1,table.getn(CS.ShamanTotems[element]) do if CS:GetChoiceSpell(CS.ShamanTotems[element][n]) then table.insert(list,CS.ShamanTotems[element][n]) end end
        local cur=set[element] or "NONE"; local idx=1; for n=1,table.getn(list) do if list[n].key==cur then idx=n break end end
        idx=idx+1; if idx>table.getn(list) then idx=1 end; set[element]=list[idx].key; CS:QueueRefresh(); CS:RefreshConfig()
    end
    for i=1,4 do
        local element,label=elements[i][1],elements[i][2]
        local l=AddDyn(p,p:CreateFontString(nil,"OVERLAY","GameFontNormal")); l:SetPoint("TOPLEFT",p,"TOPLEFT",0,-32-(i-1)*27); l:SetText(label.." :")
        local c=CS:GetShamanChoice(element,set[element])
        local txt=(c and not c.allowEmpty) and CS:GetChoiceName(c) or "Aucun"
        local b=AddDyn(p,MakeButton(p,txt,300,22)); b:SetPoint("TOPLEFT",p,"TOPLEFT",75,-27-(i-1)*27); b:SetScript("OnClick",function() Cycle(element) end)
    end
end

function CS:BuildWarlockConfig(p)
    local w=self.char.warlock; if w.maxShards==nil then w.maxShards=12 end; if w.autoDelete==nil then w.autoDelete=false end
    local title=AddDyn(p,p:CreateFontString(nil,"OVERLAY","GameFontHighlight")); title:SetPoint("TOPLEFT",p,"TOPLEFT",0,0); title:SetText("Fragments d'âme")
    local c=AddDyn(p,MakeCheck(p,"Supprimer automatiquement au-dessus du seuil")); c:SetPoint("TOPLEFT",p,"TOPLEFT",0,-24); c:SetChecked(w.autoDelete); c:SetScript("OnClick",function() w.autoDelete=this:GetChecked() and true or false; CS:HandleSoulShards() end)
    local l=AddDyn(p,p:CreateFontString(nil,"OVERLAY","GameFontNormal")); l:SetPoint("TOPLEFT",p,"TOPLEFT",0,-64); l:SetText("Maximum : "..tostring(w.maxShards))
    local minus=AddDyn(p,MakeButton(p,"-",28,20)); minus:SetPoint("LEFT",l,"RIGHT",10,0); minus:SetScript("OnClick",function() w.maxShards=math.max(0,(tonumber(w.maxShards) or 12)-1); CS:HandleSoulShards(); CS:RefreshConfig() end)
    local plus=AddDyn(p,MakeButton(p,"+",28,20)); plus:SetPoint("LEFT",minus,"RIGHT",6,0); plus:SetScript("OnClick",function() w.maxShards=math.min(40,(tonumber(w.maxShards) or 12)+1); CS:RefreshConfig() end)
end

function CS:RefreshConfig()
    local f=self.configFrame; if not f or not self.db then return end
    
    f.lock:SetChecked(self.db.locked)
    f.visible:SetChecked(self.db.visible)

    f.scaleSlider:SetValue((self.db.scale or 1) * 100)
    f.buttonScaleSlider:SetValue((self.db.buttonScale or 1) * 100)
    f.radiusSlider:SetValue(self.db.radius or 82)
    f.angleSlider:SetValue(self.db.angle or 0)

    local menuDelay = tonumber(self.db.menuAutoCloseDelay) or 6
    f.menuDelaySlider:SetValue(menuDelay)

    if menuDelay <= 0 then
        f.menuDelayLabel:SetText("Fermeture auto des menus : désactivée")
    else
        f.menuDelayLabel:SetText(
            "Fermeture auto des menus : " .. menuDelay .. " s"
        )
    end
    
    local def=self.classDefs[self.class]; local defs=def and self:GetOrderedDefs(def) or {}
    local i
    for i=1,9 do
        local row=f.rows[i]; local cfg=defs[i]
        if cfg then
            row:Show(); row.check.text:SetText(cfg.label or cfg.id); row.check:SetChecked(self:IsButtonEnabled(cfg.id,cfg.default)); row.check.csId=cfg.id; row.check:SetScript("OnClick",function() CS.char.buttons[this.csId]=this:GetChecked() and true or false; CS:QueueRefresh() end)
            row.up.csId=cfg.id; row.up:SetScript("OnClick",function() CS:MoveOrder(this.csId,-1) end); row.down.csId=cfg.id; row.down:SetScript("OnClick",function() CS:MoveOrder(this.csId,1) end)
        else row:Hide() end
    end
    ClearPanel(f.classPanel)
    if self.class=="SHAMAN" then self:BuildShamanConfig(f.classPanel) elseif self.class=="WARLOCK" then self:BuildWarlockConfig(f.classPanel) else
        local t=AddDyn(f.classPanel,f.classPanel:CreateFontString(nil,"OVERLAY","GameFontNormal")); t:SetPoint("TOPLEFT",f.classPanel,"TOPLEFT",0,0); t:SetText("Les réglages spécifiques de cette classe se font\navec un clic droit sur les boutons de groupe.")
    end
end

function CS:ToggleConfig()
    self:EnsureConfig()
    if self.configFrame:IsVisible() then self.configFrame:Hide() else self:RefreshConfig(); self.configFrame:Show() end
end
