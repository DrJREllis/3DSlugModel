% A function to take the coordinates of slugs and partition them into bins
function [Corr,Brange] = SlugBinning(Nbins,Lx,Ly,X,Y,U,name)

Nk = size(X,1);
Nt = size(X{1},1);

Corr=zeros(Nt,Nk);
Brange=zeros(Nt,2,Nk);
BinPop=zeros(Nbins^2,2,Nt);

for uORo = 0:1 % 1=overground, 0=underground

    
    if uORo == 1
        loc='overground';
    else 
        loc= 'underground';
    end

    for k=1:Nk
        Pxh=X{k}; Pyh=Y{k}; Puh=U{k};
        
        if uORo==1
            Pxh1=Pxh.*Puh; Pyh1=Pyh.*Puh;
        else
            Pxh1=Pxh.*(1-Puh); Pyh1=Pyh.*(1-Puh);
        end
        Pxh1(Pxh1==0)=nan; Pyh1(Pyh1==0)=nan;
    
        for j=1:Nt
            %Calculate the bin populations and reformat for contour plots
            Pt(:,:,j)=histcounts2(Pxh1(j,:),Pyh1(j,:),0:Lx/Nbins:Lx,0:Ly/Nbins:Ly);
            Pt(:,:,j)=rot90(Pt(:,Nbins:-1:1,j));
    
            %Calculate Morisita index
            Q=Nbins.^2; n=Pt(:,:,j); N=sum(Pt(:,:,j),"all");
            MI(j,k,uORo+1)=Q*(sum(sum((n.*(n-1)))))/(N*(N-1));
    
            BinPop(:,uORo+1,j)=reshape(Pt(:,:,j),Nbins^2,1);
            if uORo==1
                corr1=corrcoef(BinPop(:,:,j));
                Corr(j,k)=corr1(2);
            end

            Brange(j,uORo+1,k)=range(Pt(:,:,j),"all");
    
        end
    
        %Calculate bin mean and variance of final distribution
        Bmean(k)=mean2(Pt(:,:,end));
        Bvar(k)=var(reshape(Pt(:,:,end),(Nbins)^2,1));
        Bmeanlog(k)=log(Bmean(k));
        Bvarlog(k)=log(Bvar(k));
        Ptc{k}=Pt;

end

%% Distribution Plots

figure(1)
plot(Pxh1(end,:),Pyh1(end,:),'.')
i=1;
set(i,'paperunits','centimeters');
set(i,'papersize',[16 14]);
set(i,'paperposition',[0 0 16 14]);
ax = gca;
ax.FontSize = 18;
xlim([0 Lx])
ylim([0 Ly])
xticks(0:200:1000)
xticklabels(0:2:10)
yticks(0:200:1000)
yticklabels(0:2:10)
ylabel('$y$, metres','interpreter','latex','FontSize',28)
xlabel('$x$, metres','interpreter','latex','FontSize',28);
figname = ['Figures/',name,'_distribution_',loc];
print(1,'-dpdf',[figname,'.pdf']);
savefig([figname,'.fig']);
close 

figure(1)
contourf(Ptc{1}(:,:,end))
colorbar
i=1;
set(i,'paperunits','centimeters');
set(i,'papersize',[16 14]);
set(i,'paperposition',[0 0 16 14]);
ax = gca;
ax.FontSize = 18;
xticks([1:9/5:10])
xticklabels([0:2:10])
figname = ['Figures/',name,'_contour_',loc];
yticks([1:9/5:10])
yticklabels([0:2:10])
clim([30 70])
ylabel('$y$, metres','interpreter','latex','FontSize',28)
xlabel('$x$, metres','interpreter','latex','FontSize',28);
print(1,'-dpdf',[figname,'.pdf']);
savefig([figname,'.fig']);

end
