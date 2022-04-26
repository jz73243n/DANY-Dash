FROM gitlab.dany.nycnet:5050/it-devs/image-r:2021-05-26

USER shiny
WORKDIR /srv/shiny-server/dany_dashboard
COPY . .

EXPOSE 8080
ENV PORT=8080
ENTRYPOINT ["Rscript", "run.R"]
