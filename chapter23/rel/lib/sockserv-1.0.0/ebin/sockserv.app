%% coding: utf-8
%% app generated at {2021,3,4} {15,28,27}
{application,sockserv,
             [{description,"Socket server to forward ProcessQuest messages to a client"},
              {vsn,"1.0.0"},
              {id,[]},
              {modules,[sockserv,sockserv_pq_events,sockserv_serv,
                        sockserv_sup,sockserv_trans]},
              {registered,[sockserv_sup]},
              {applications,[stdlib,kernel,processquest]},
              {included_applications,[]},
              {env,[{port,8082}]},
              {maxT,infinity},
              {maxP,infinity},
              {mod,{sockserv,[]}}]}.

