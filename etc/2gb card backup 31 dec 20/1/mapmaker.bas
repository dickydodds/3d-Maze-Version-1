PLUS3DOS e   ���                                                                                                         P  �Mapmaker ver .1 Dec 2020  �32767  �  
 �"3dmaze.bin"�32768   �   �GO SUB 8200: REM do udg's � �drawmap=35664  P� :�curmap=64034  "� :�mapdata=41728   � :�mapstart=64035  #� :�pdir=64008  � :�setmap=51109  �� :�mapstartpos=45824   � :�playerpos=64000   � :�drawview=50801  q� :�playerstartpos=45824   �   �map=0      :�POKE 35921,56 A �pdir,2    :�curmap,0     :�mapstart,(map*256    )+mapdata  . �setmap+1    ,map:�64000   � ,41729   �  	 ��setmap #5 �35665  Q� ,48  0  :�2=red walls 66=bright red, 48 ( �500  � � �f=0     �255  �  �$ �35665  Q� ,f:��20    ,0     ;f�
 ��drawmap�	 �0     � �f� �� � UDG's                    �' �5    :�7    :�9  	  :�:��drawmap�= ��0     ,0     ;�0     ;�6    ;"GET OUT Map Maker V0.1"�& ��18    ,23    ;�1    ;" MOVE "� ��19    ,23    ;"  7"� ��20    ,23    ;" 5 8" ��21    ,23    ;"  6"( ��11    ,23    ;�1    ;" SYSTEM "$8 ��12    ,22    ;"di";�2    ;"R";�9  	  ;"ection".4 ��14    ,22    ;�2    ;"M";�9  	  ;"em save"88 ��13    ,22    ;"draw ";�2    ;"V";�9  	  ;"iew"B8 ��15    ,22    ;"d";�2    ;"I";�9  	  ;"sk save"G9 ��16    ,22    ;"m";�2    ;"A";�9  	  ;"p Number"L' ��0     ,23    ;�1    ;" EDITOR "Q  �a$="s":�3812  � :�face south`O ��1    ,22    ;�1    ;�7    ;"X";�7    ;�2    ;"=W";�9  	  ;"all"tQ ��2    ,22    ;�1    ;�7    ;"P";�7    ;�2    ;"=P";�9  	  ;"layer"~Q ��3    ,22    ;�1    ;�7    ;"S";�7    ;�2    ;"=S";�9  	  ;"witch"�P ��4    ,22    ;�1    ;�7    ;"E";�7    ;�2    ;"=E";�9  	  ;"xit "�G ��0     ;�5    ,22    ;�9  	  ;" de";�2    ;"L";�9  	  ;"ete"�= ��0     ;�6    ,22    ;" ";�2    ;"C";�9  	  ;"lear"�< ��0     ;�7    ,22    ;�2    ;" G";�9  	  ;"en new"� �main loop� �col = 5 to 19             � �line  = 3 to 18�	 �5    � �6000  p � �l=3    :�p=5    � �o$=�(l,p)� �PRINT AT 0,0;o$�, �oldl=l:�oldp=p:��l,p;�2    ;�1    ;" "�< ��21    ,0     ;�1    ;�9  	  ;"Current Map=";map;" "� �k$=��8 �k$ ="7"��l=l-1    :�l<3    ��l=3    :�1580  , : �k$ ="6"��l=l+1    :�l>18    ��l=18    :�1580  , 8 �k$ ="5"��p=p-1    :�p<5    ��p=5    :�1580  , : �k$ ="8"��p=p+1    :�p>19    ��p=19    :�1580  , ,+ �k$ ="c"��l=3    :�p=8    :�3500  � 1 �k$ ="l"���l,p;" ":�o$=" "6 �k$ ="s"���l,p;"S":�o$="S";9 �k$ ="v"��l=3    :�p=8    :�:�3700  t :�1000  � E �k$ ="r"��3800  � J$ �k$ ="w"���l,p;�1    ;"X":�o$="X"O$ �k$ ="s"���l,p;�3    ;"S":�o$="S"T$ �k$ ="e"���l,p;�4    ;"E":�o$="E"Y$ �k$ ="p"���l,p;�6    ;"P":�o$="P"^� �k$ ="i"��"usermap.bin":��20    ,0     ;"Saving      ":�"usermap.bin"�41728   � ,4143  / :��20    ,0     ;"last save ok":�400  � r �k$ ="m"��3900  < | �k$ ="g"��5000  � �' �k$ ="a"��4500  � :�m$�"n"��26    �5 �o$="X"���9  	  ;�1    ;�oldl,oldp;o$:�1520  � �5 �o$="S"���9  	  ;�3    ;�oldl,oldp;o$:�1520  � �5 �o$="E"���9  	  ;�4    ;�oldl,oldp;o$:�1520  � �5 �o$="P"���9  	  ;�6    ;�oldl,oldp;o$:�1520  � � ��oldl,oldp; o$�" �f=0     �10  
  :�f:�key pause �1520  � �  �! �"Clear Maze. Are you sure? ";a$�
 �a$�"y"��� �f=3    �18    �' ��5    ;�f,5    ;"               "� �f� �t �draw player view�/ �curmap,map:�mapstart,(map*256    )+mapdata � ��drawview�D ��3    :�f=0     �768    :�22528   X +f,56  8  :�f:��0     � �10  
  :�0     � �� �set player view direction� �"N, S, E, W? ";a$�) ��9  	  ,22    ;�1    ;"Player Dir"�@ �a$="n"���10  
  ,26    ;�2    ;�9  	  ;"N":�pdir,0     �@ �a$="w"���10  
  ,26    ;�2    ;�9  	  ;"W":�pdir,1     @ �a$="s"���10  
  ,26    ;�2    ;�9  	  ;"S":�pdir,2    
@ �a$="e"���10  
  ,26    ;�2    ;�9  	  ;"E":�pdir,3    ( �< �save map to memoryA �"Save to Memory?";m$F �m$="n"��1520   � K
 ��3    P �PRINT AT l,p;o$U �l=3    �18    Z �p=5    �19    _. �PRINT AT 21,0;l;" , ";p;" = "; SCREEN$ (l,p)d ��l,p;�1    ;�2    ;" "i �a=�(�(l,p))n �a=�"X"��a=128  �  q �IF a= CODE "D" THEN LET a=50u �a=�" "��a=32     x �a=�"S"��a=224  �  { �a=�"E"��a=192  �  �p �a=�"P"��playerpos=3    *map+playerstartpos:�a=32     :�playerpos,((l-3    )*16    )+(p-5    +1    )�A �PRINT AT 0,0; (map*256+mapdata)+((l-3)*16)+(p-5+1);"  " ,a;"  "�F �(map*256    +mapdata)+((l-3    )*16    )+(p-5    +1    ),a�( �PRINT AT 1,0;((l-3)*16)+(p-5+1),a;"  "�# �POKE playerpos,((l-3)*16)+(p-5+1)� �p:�l �1000   � � �set current map�; �"Change Map - this will lose all unsaved changes. Y/N";m$�
 �m$="n"��� �"map number (0 to 15)";m� �m>16    ��4510  � � �map=m�- �curmap,m:�mapstart,(map*256    )+mapdata �& �playerpos=3    *map+playerstartpos�2 �PRINT AT 0,0;3*map+playerstartpos,"3*map=";3*map� �� �generate random map� ��3    :��' �"Generate new map Y/N ?";a$:�a$�"y"��� ��3    :�� �f=3    �18    � �t=5    �19    �D �r=�(�*3     ):�r=1    ���1    ;�9  	  ;�f,t;"X" :���f,t;" "� �t:�f� ��0     :�p �draw mazeu
 ��drawmapzO ��3    :�c=map*256    +41728   � :�f=3    �18    :�t=4    �19    � �s=�c� �LET a$=" "�, �s=128  �  �s=129  �  ���f,t;�1    ;"X"�  �s=192  �  ���f,t;�4    ;"E"�  �s=224  �  ���f,t;�3    ;"S"� �PRINT AT f,t;a$� �c=c+1    � �t:�f�/ ��3    ,5    ;" ":�erase player 1 position�, �c=�playerpos:�PRINT AT 1,0;"player pos=";c�$ �PRINT AT 20,0;"player pos=";c;"  "�  �x=�(c/16    )+3    :�line �F �c>16    ��y=(c-16    *(x-3    ))+4    :��y=4    +c:�column� �PRINT AT 20,0;x;"  ";y;"  "� ��x,y;�9  	  ;�6    ;"P"� ��0     :�'7 �"Stack End = ";�23653  e\ +256    *�23654  f\ :� '  �"mapmaker.bas":�"mapmaker.bas"�rawma�  P� �urma�  "� �apdat�   � �apstar�  #� �di�  � �etma�  �� �apstartpo�   � �layerpo�   � �rawvie�  q� �layerstartpo�   � �a�     c    �      
      ��            zs     x    y    �            U�            Z�ld�    �ld�    a     m     r     M  A sK  O  