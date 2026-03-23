
hprime = 71:1:80;
beta = .31:.01:0.4;
h_0 = 64:4:100;

qe = 1.602176634e-19; %C
eps0 = 8.8541878128e-12; %F/m
me = 9.1093837015e-31; %kg
wrprime = 2.5e5;

for hh=1:length(hprime)
    for bb=1:length(beta)
        for tt=1:length(h_0)
            h = [20:5:75 77:2:120];
            enEXP{hh,bb,tt} = 1.43*1e7*exp(-0.15*hprime(hh))*exp((beta(bb)-0.15)*(h-hprime(hh)));
            
            Htest = 5.01:.01:25;
            betatest = (0.5./Htest).*(exp(-((hprime(hh)-h_0(tt))./Htest))-1);
            [~,betaind] = min(abs(betatest-beta(bb)));
            H = Htest(betaind);
            
            nuprime = 5e6*exp(-0.15*(hprime(hh)-70));
            enprime = wrprime*nuprime*eps0*me./(qe.^2)./100.^3; %electron density at the reflection height in cm^-3
            
            zprime = (hprime(hh)-h_0(tt))./(H);
            N_0 = enprime*exp(-0.5*(1-zprime-exp(-zprime)));
            
            z = (h-h_0(tt))./H;
            enCHA{hh,bb,tt} = N_0.*exp(0.5.*(1-z-exp(-z)));
        end
    end
end



%% --- Convert cell array C -> numeric array A ---
clr = zeros(10,10,10,34);

for i = 1:10
    for j = 1:10
        for k = 1:10
            clr(i,j,k,:) = enEXP{i,j,k};
            B(i,j,k,:) = enCHA{i,j,k};
        end
    end
end


gifFile = 'densities.gif';
delayTime = 1;
fig1 = figure('Color','w');
set(fig1,'Position',[100 100 900 400])
for ii = 1:34
    subplot(1,2,1)
    imagesc(squeeze(A(:,1,:,ii)))
    axis xy
    colorbar
    subplot(1,2,2)
    imagesc(squeeze(B(:,1,:,ii)))
    axis xy
    colorbar
    drawnow
    frame = getframe(fig1);
    
    im = frame2im(frame);
    [clr,map] = rgb2ind(im,256);
    if ii == 1
        imwrite(clr,map,gifFile,'gif','LoopCount',inf,'DelayTime',delayTime);
    else
        imwrite(clr,map,gifFile,'gif','WriteMode','append','DelayTime',delayTime);
    end
end














% %% --- Create figure and UI ---
% fig = figure;
% 
% % Slider for k
% s_k = uicontrol(fig,'Style','slider',...
%     'Min',1,'Max',10,'Value',1,...
%     'SliderStep',[1/9 1/9],...
%     'Position',[20 20 200 20],...
%     'Callback', @update_plot);
% 
% % Slider for vector index
% s_v = uicontrol(fig,'Style','slider',...
%     'Min',1,'Max',34,'Value',1,...
%     'SliderStep',[1/33 1/33],...
%     'Position',[240 20 200 20],...
%     'Callback', @update_plot);
% 
% % Store everything safely
% data.A = A;
% data.s_k = s_k;
% data.s_v = s_v;
% 
% guidata(fig, data);
% 
% % Initial plot
% update_plot(fig);
% fig = figure;
% 
% % Slider for k
% s_k = uicontrol(fig,'Style','slider',...
%     'Min',1,'Max',10,'Value',1,...
%     'SliderStep',[1/9 1/9],...
%     'Position',[20 20 200 20],...
%     'Callback', @update_plot);
% 
% % Slider for vector index
% s_v = uicontrol(fig,'Style','slider',...
%     'Min',1,'Max',34,'Value',1,...
%     'SliderStep',[1/33 1/33],...
%     'Position',[240 20 200 20],...
%     'Callback', @update_plot);
% 
% % Store everything safely
% data.A = A;
% data.s_k = s_k;
% data.s_v = s_v;
% 
% guidata(fig, data);
% 
% % Initial plot
% update_plot(fig);
% %% --- Create figure and UI ---
% fig2 = figure;
% 
% % Slider for k
% s_k = uicontrol(fig2,'Style','slider',...
%     'Min',1,'Max',10,'Value',1,...
%     'SliderStep',[1/9 1/9],...
%     'Position',[20 20 200 20],...
%     'Callback', @update_plot);
% 
% % Slider for vector index
% s_v = uicontrol(fig2,'Style','slider',...
%     'Min',1,'Max',34,'Value',1,...
%     'SliderStep',[1/33 1/33],...
%     'Position',[240 20 200 20],...
%     'Callback', @update_plot);
% 
% % Store everything safely
% data2.A = B;
% data2.s_k = s_k;
% data2.s_v = s_v;
% 
% guidata(fig2, data2);
% 
% % Initial plot
% update_plot(fig2);
% fig2 = figure;
% 
% % Slider for k
% s_k = uicontrol(fig2,'Style','slider',...
%     'Min',1,'Max',10,'Value',1,...
%     'SliderStep',[1/9 1/9],...
%     'Position',[20 20 200 20],...
%     'Callback', @update_plot);
% 
% % Slider for vector index
% s_v = uicontrol(fig2,'Style','slider',...
%     'Min',1,'Max',34,'Value',1,...
%     'SliderStep',[1/33 1/33],...
%     'Position',[240 20 200 20],...
%     'Callback', @update_plot);
% 
% % Store everything safely
% data2.A = B;
% data2.s_k = s_k;
% data2.s_v = s_v;
% 
% guidata(fig2, data);
% 
% % Initial plot
% update_plot(fig2);
% 
% %% --- Callback function ---
% function update_plot(src, ~)
% 
%     % Get figure handle safely
%     if isa(src,'matlab.ui.Figure')
%         fig = src;
%     else
%         fig = ancestor(src,'figure');
%     end
% 
%     data = guidata(fig);
% 
%     % Safety check (prevents your error)
%     if isempty(data) || ~isvalid(data.s_k) || ~isvalid(data.s_v)
%         return
%     end
% 
%     k_val   = round(data.s_k.Value);
%     vec_val = round(data.s_v.Value);
% 
%     imagesc(data.A(:,:,k_val,vec_val))
%     colorbar
% 
%     title(sprintf('k = %d, vec = %d', k_val, vec_val))
% 
% end