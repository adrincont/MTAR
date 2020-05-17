#' @importFrom ggplot2 autoplot
#' @export
ggplot2::autoplot
autoplot.regim_model = function(object, type = 1) {
  if (!requireNamespace('ggplot2', quietly = TRUE)) {
    stop('ggplot2 is needed for this function to work')
  }else {
    if (!inherits(object, 'regim_model')) {
      stop('autoplot.regim_model requires a regim_model object')
    }}
  if (!{type %in% c(1:5)}) {stop('type should take values in c (1,2,3,4)')}
  if (is.null(object$Chain)) {stop('There are no chains to graph')}
  if (type == 1) {
    if (is.null(object$Chain$r)) {stop('r unknown')}
    Chain_r = t(object$Chain$r)
    time = seq(1,nrow(Chain_r))
    dat2 = data.frame(name = 'r1',time = time,value = Chain_r[,1])
    if (ncol(Chain_r) > 1) {
      for (i in 2:ncol(Chain_r)) {
        dat2 = rbind(dat2,data.frame(name = paste0('r',i),
                                     time = time,value = Chain_r[,i]))
      }
    }
    p = ggplot2::ggplot(data = dat2,ggplot2::aes(x = time,y = dat2$value))
    p = p + ggplot2::geom_line() + ggplot2::facet_grid(name~.,scales = 'free') + ggplot2::theme_bw()
    p = p +  ggplot2::labs(title = 'Thresholds chains')
    return(p)
    }
  if (type == 2) {
    # Sigma Chains
    Chain_Sig = object$Chain$Sigma
    dat3l = vector(mode = 'list',length = length(Chain_Sig))
    p3 = vector(mode = 'list',length = length(Chain_Sig))
    names(p3) = names(Chain_Sig)
    names(dat3l) = names(Chain_Sig)
    if (!is.matrix(Chain_Sig$R1)) {
      Chain_Sig$R1 = t(as.matrix(Chain_Sig$R1))
    }
    time = seq(1,ncol(Chain_Sig$R1))
    for (j in names(Chain_Sig)) {
      dat3 = data.frame(comp = '11',time = time,value = Chain_Sig[[j]][1,])
      k = dim(object$regime[[j]]$sigma)[1]
      names_sig = paste0(1:k,1)
      for (i3 in 2:k) {names_sig = c(names_sig,paste0(1:k,i3))}
      if (nrow(Chain_Sig[[j]]) > 1) {
        ii = 1
        for (i in names_sig[-1]) {
          dat3 = rbind(dat3,data.frame(comp = i,time = time,value = Chain_Sig[[j]][ii,]))
          ii = ii + 1
        }
      }
      p3[[j]] = ggplot2::ggplot(data = dat3,ggplot2::aes(x = time,y = dat3$value)) +
        ggplot2::geom_line() + ggplot2::facet_grid(comp~.,scales = 'free') +
        ggplot2::theme_bw() +
        ggplot2::labs(title = paste('Sigma chains',j))
      }
    return(p3)
    }
  if (type == 3) {
    # Theta Chains
    Chain_Theta = object$Chain$Theta
    dat3l = vector(mode = 'list',length = length(Chain_Theta))
    p4 = vector(mode = 'list',length = length(Chain_Theta))
    names(p4) = names(Chain_Theta)
    if (!is.matrix(Chain_Theta$R1)) {
      Chain_Theta$R1 = t(as.matrix(Chain_Theta$R1))
    }
    time = seq(1,ncol(Chain_Theta$R1))
    for (j in names(Chain_Theta)) {
      dat3 = data.frame(comp = '1',time = time,value = Chain_Theta[[j]][1,])
      if (ncol(Chain_Theta[[j]]) > 1) {
        for (i in 2:nrow(Chain_Theta[[j]])) {
          dat3 = rbind(dat3,data.frame(comp = as.character(i),
                                       time = time,value = Chain_Theta[[j]][i,]))
        }
      }
      p4[[j]] = ggplot2::ggplot(data = dat3,ggplot2::aes(x = time,y = dat3$value)) +
        ggplot2::theme_bw() +
        ggplot2::geom_line() + ggplot2::facet_grid(comp~.,scales = 'free') +
        ggplot2::labs(title = paste('Theta chains',j))
      }
    return(p4)
  }
  if (type == 4) {
    # Gamma Chains
    if (is.null(object$Chain$Gamma)) {
      stop('Object $Chain$Gamma does not exist (known orders)')
    }
    Chain_Gamma = object$Chain$Gamma
    dat3l = vector(mode = 'list',length = length(Chain_Gamma))
    p5 = vector(mode = 'list',length = length(Chain_Gamma))
    names(p5) = names(Chain_Gamma)
    time = seq(1,ncol(Chain_Gamma$R1))
    for (j in names(Chain_Gamma)) {
      dat3 = data.frame(comp = '1',time = time,value = Chain_Gamma[[j]][1,])
      if (ncol(Chain_Gamma[[j]]) > 1) {
        for (i in 2:nrow(Chain_Gamma[[j]])) {
          dat3 = rbind(dat3,data.frame(comp = as.character(i),
                                       time = time,value = Chain_Gamma[[j]][i,]))
        }
      }
      p5[[j]] = ggplot2::ggplot(data = dat3,ggplot2::aes(x = time,y = dat3$value)) +
        ggplot2::geom_line() + ggplot2::facet_grid(comp~.,scales = 'free') +
        ggplot2::theme_bw() +
        ggplot2::labs(title = paste('Gamma chains',j))
    }
    return(p5)
  }
  if (type == 5) {
    Chain_Yt = as.data.frame(object$data$Yt)
    Chain_fit = as.data.frame(object$fitted.values)
    time = seq(1,nrow(Chain_fit))
    dat1 = data.frame(type = 'obs',name = 'Series.1',time = time, value = Chain_Yt[,1])
    dat1 = rbind.data.frame(dat1,data.frame(type = 'fit',name = 'Series.1',time = time, value = Chain_fit[,1]))
    if (ncol(Chain_Yt) > 1) {
      for (i in 2:ncol(Chain_Yt)) {
        dati = data.frame(type = 'obs',name = paste0('Series.',i),time = time,value = Chain_Yt[,i])
        dati = rbind.data.frame(dati,data.frame(type = 'fit',name = paste0('Series.',i),time = time, value = Chain_fit[,i]))
        dat1 = rbind.data.frame(dat1,dati)
      }
    }
    p = ggplot2::ggplot(data = dat1,ggplot2::aes(x = time,y = dat1$value, color = type))
    p = p + ggplot2::geom_line() + ggplot2::facet_grid(name~.) + ggplot2::theme_bw()
    p = p + ggplot2::labs(title = 'Output process')
    p = p + ggplot2::scale_color_manual(values = c("black","blue"))
    return(p)
  }
}
autoplot.regim_missing = function(object, type = 1) {
    if (!requireNamespace('ggplot2', quietly = TRUE)) {
      stop('ggplot2 is needed for this function to work')
    }else {
      if (!inherits(object, 'regim_missing')) {
        stop('autoplot.regim_missing requires a regim_missing object')
      }}
    if (is.null(object$Chains$Y)) {stop('There are no chains to graph')}
    if (!{type %in% c(1:2)}) {stop('type should take values in c (1,2,3)')}
    if (type == 1) {
      if (is.null(object$estimates$Yt)) {stop('Yt has no missing data')}
      Chain_Yt = t(object$Chains$Yt)
      time = seq(1,nrow(Chain_Yt))
      names_yt = rownames(object$estimates$Yt)
      dat2 = data.frame(name = names_yt[1],time = time,value = Chain_Yt[,1])
      if (ncol(Chain_Yt) > 1) {
        for (i in 2:ncol(Chain_Yt)) {
          dat2 = rbind(dat2,data.frame(name = names_yt[i],time = time,value = Chain_Yt[,i]))
        }
      }
      p = ggplot2::ggplot(data = dat2,ggplot2::aes(x = time,y = dat2$value))
      p = p + ggplot2::geom_line() + ggplot2::facet_grid(name~.,scales = 'free') + ggplot2::theme_bw()
      p = p +  ggplot2::labs(title = 'Missing data (Yt) chains')
      return(p)
    }
    if (type == 2) {
      if (is.null(object$estimates$Ut)) {stop('Ut = [Zt,Xt] has no missing data')}
      Chain_Ut = t(object$Chains$Ut)
      time = seq(1,nrow(Chain_Ut))
      names_ut = rownames(object$estimates$Ut)
      dat2 = data.frame(name = names_ut[1],time = time,value = Chain_Ut[,1])
      if (ncol(Chain_Ut) > 1) {
        for (i in 2:ncol(Chain_Ut)) {
          dat2 = rbind(dat2,data.frame(name = names_ut[i],time = time,value = Chain_Ut[,i]))
        }
      }
      p = ggplot2::ggplot(data = dat2,ggplot2::aes(x = time,y = dat2$value))
      p = p + ggplot2::geom_line() + ggplot2::facet_grid(name~.,scales = 'free') + ggplot2::theme_bw()
      p = p +  ggplot2::labs(title = 'Missing data (Ut = [Zt,Xt]) chains')
      return(p)
    }
  }
autoplot.tsregim = function(object, type = 1) {
  if (!requireNamespace('ggplot2', quietly = TRUE)) {
    stop('ggplot2 is needed for this function to work')
  }else {
    if (!inherits(object, 'tsregim')) {
      stop('autoplot.tsregim requires a tsregim object')
    }}
  if (!{type %in% c(1:3)}) {stop('type should take values in c (1,2,3)')}
  dats_Yt = as.data.frame(object$Yt)
  time = seq(1,nrow(dats_Yt))
  dat = data.frame(name = 'Series.1',time = time,value = dats_Yt[,1])
  if (ncol(dats_Yt) > 1) {
    for (i in 2:ncol(object$Yt)) {
      dat = rbind(dat,data.frame(name = paste0('Series.',i),time = time,value = dats_Yt[,i]))
    }
  }
  p = ggplot2::ggplot(data = dat,ggplot2::aes(x = time,y = dat$value))
  p = p + ggplot2::geom_line() + ggplot2::facet_grid(name~.) + ggplot2::theme_bw()
  p = p + ggplot2::labs(title = 'Output process')
  p = p + ggplot2::geom_vline(xintercept = dat$time[is.na(dat$value)],color = "red",linetype = 'dashed')
  if (!is.null(object$Zt)) {
    dats_Zt = data.frame(time = time,value = object$Zt)
    p2 = ggplot2::ggplot(data = dats_Zt,ggplot2::aes(x = time,y = dats_Zt$value))
    p2 = p2 + ggplot2::geom_line() + ggplot2::theme_bw()
    p2 = p2 + ggplot2::geom_vline(xintercept = dats_Zt$time[is.na(dats_Zt$value)],color = "red",linetype = 'dashed')
    if (!is.null(object$r)) {
      Nrg_plot = paste0(paste0(paste0('Reg_',1:object$l),'='),object$Summary_r$Prop_reg,'%')
      p2 = p2 + ggplot2::labs(title = 'Threshold process',subtitle = paste0('(',paste(Nrg_plot,collapse = ','),')'))
      for (i in c(object$r)) {
        p2 = p2 + ggplot2::geom_hline(yintercept = i,linetype = 'dashed',color = 'blue')
      }
    }
  }
  if (!is.null(object$Xt)) {
    dats_Xt = as.data.frame(object$Xt)
    dat2 = data.frame(name = 'Series.1',time = time,value = dats_Xt[,1])
    if (ncol(dats_Xt) > 1) {
      for (i in 2:ncol(object$Xt)) {
        dat2 = rbind(dat2,data.frame(name = paste0('Series.',i),
                                     time = time,value = dats_Xt[,i]))
      }
    }
    p3 = ggplot2::ggplot(data = dat2,ggplot2::aes(x = time,y = dat2$value))
    p3 = p3 + ggplot2::geom_line() + ggplot2::facet_grid(name~.) + ggplot2::theme_bw()
    p3 = p3 + ggplot2::labs(title = 'Covariates process')
    p3 = p3 + ggplot2::geom_vline(xintercept = dat2$time[is.na(dat2$value)],color = "red",linetype = 'dashed')
  }
  if (type == 1) {
    return(p)
  }
  if (type == 2) {
    if (is.null(object$Zt)) {
      stop('Threshold process does not exist')}
    return(p2)
  }
  if (type == 3) {
    if (is.null(object$Xt)) {
      stop('Covariates process does not exist')}
    return(p3)
  }
}

base::registerS3method('autoplot','regim_model', autoplot.regim_model)
base::registerS3method('autoplot','regim_missing', autoplot.regim_missing)
base::registerS3method('autoplot', 'tsregim', autoplot.tsregim)

print = function(object) UseMethod('print')

print.tsregim = function(object,...){
  cat('Threshold time series:\n','N =',object$N,'\n')
  dats = object
  class(dats) = NULL
  if (!is.null(object$r)) {
    cat('======================','\n')
    cat('r = ',object$r,'\n')
    print(object$Summary_r)
    cat('======================','\n')
  }else{
    if (!is.null(object$Zt)) {
      cat('Unknown threshold values','\n')
    }
  }
  utils::str(dats)
}
print.regim_model = function(object,...) {
  print(object$estimates)
}
print.regim_missing = function(object,...) {
  print(object$estimates)
}
base::registerS3method('print','regim_model', print.regim_model)
base::registerS3method('print','regim_missing', print.regim_missing)
base::registerS3method('print', 'tsregim', print.tsregim)