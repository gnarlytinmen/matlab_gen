function [] = centang(poi,points)
% Finds central angle between two points in polar coordinates
%
% Usage: [] = centang()

rawcents = points - poi;

rawcents = rawcents(rawcents>180)-180;

end