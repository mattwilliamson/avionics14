%% Calibrate
function [M,B] = Calibrate()
% Assumes the system Calibrated = ScaleM * (Measurement - Bias)
% Where ScaleM is a 3x3 symmetric matrix and Bias is a 3D vector
% The values are found using a damped Gaus-Newton nonlinear solver
% There is probably a way to do this using built in functions but I
% couldn't get any of them to provide an adequate solution

global X;
global n;
global lambda;
global k;

format long

% Solver Parameters
lambda = 1; % Damping Gain
k = 0.1; % Damping parameter
tolerance = 1e-6;

% A final scaling parameter
desiredR = 9.80665;

X = load('AccelData3.txt');
[n, ~] = size(X);

%% Fit Ellipsoid to the data
[e_center, e_radii, e_eigenvecs, e_algebraic] = ellipsoid_fit([ X(:,1),  X(:,2),  X(:,3)]);
% compensate distorted magnetometer data
% e_eigenvecs is an orthogonal matrix, so ' can be used instead of inv()
scale = inv([e_radii(1) 0 0; 0 e_radii(2) 0; 0 0 e_radii(3)]) * min(e_radii); % scaling matrix
scale2 = [1/e_radii(1) 0 0; 0 1/e_radii(2) 0; 0 0 1/e_radii(3)];
map = e_eigenvecs'; % transformation matrix to map ellipsoid axes to coordinate system axes
transmap = e_eigenvecs; % transpose of above
comp = transmap * scale * scale2 * map;


%% Use the ellipsoid as the starting point for the gauss-newton solver

maxIter = 100;

v = zeros(1,9);
v(1) = comp(1,1);
v(2) = comp(1,2);
v(3) = comp(1,3);
v(4) = comp(2,2);
v(5) = comp(2,3);
v(6) = comp(3,3);
v(7) = e_center(1);
v(8) = e_center(2);
v(9) = e_center(3);


R = 18535588;

[v, R] = computeNextEstimate(v, R);

for i = 1:maxIter
    oldV = v;
    [v,R] = computeNextEstimate(v, R);
    
    if (max(abs(v - oldV)) <= tolerance)
        fprintf('Convergence Achieved!\n');
        break;
    end
end


M = [v(1) v(2) v(3); v(2) v(4) v(5); v(3) v(5) v(6)];
M(1,1) = M(1,1) * desiredR;
M(2,2) = M(2,2) * desiredR;
M(3,3) = M(3,3) * desiredR;
B = [v(7);v(8);v(9)];

%% Plotting

% Plot un-calibrated data
figure(1);
clf
hold on

grid on

scatter3(X(:,1),X(:,2),X(:,3),5,[0 0 0], 'x');

[x, y, z] = sphere(128);
h = surfl(x, y, z);
set(h, 'FaceAlpha', 0.25)
shading interp

hold off

% Plot Ellipsoid fit

figure(2);
clf
hold on

grid on

Transformed = zeros(n,3);
DataRange = 1:n;
Error = 0;
for i = DataRange
    Transformed(i,:) = comp*(transpose(X(i,:) - transpose(e_center)));
    Error = Error + (norm(Transformed(i,:))-1)^2;
end
fprintf('Error for ellipsoid %0.9g\n',Error);

scatter3(Transformed(:,1),Transformed(:,2),Transformed(:,3),5,[0 0 0], 'x');

[x, y, z] = sphere(128);
h = surfl(x, y, z);
set(h, 'FaceAlpha', 0.5)
shading interp
hold off


% Plot Calibrated Data
figure(3);
clf
hold on

grid on

Transformed = zeros(n,3);
DataRange = 1:n;
Error = 0;
for i = DataRange
    Transformed(i,:) = M*(transpose(X(i,:)) - B);
    Error = Error +  (norm(Transformed(i,:))/desiredR - 1)^2;
end

fprintf('Error for adjusted ellipsoid %0.9g\n',Error);

scatter3(Transformed(:,1),Transformed(:,2),Transformed(:,3),5,[0 0 0], 'x');

[x, y, z] = sphere(128);
x = x * desiredR;
y = y * desiredR;
z = z * desiredR;
h = surfl(x, y, z);
set(h, 'FaceAlpha', 0.5)
shading interp
hold off
end

%% Solver

function [ v , newR] = computeNextEstimate(v, lastR)
global X;
global n;
global lambda;
global k;

newR = 0;
Jacobian = zeros(n,9);
D = zeros(9,1);

ScaleMxx = v(1);
ScaleMxy = v(2);
ScaleMxz = v(3);
ScaleMyy = v(4);
ScaleMyz = v(5);
ScaleMzz = v(6);
BiasX = v(7);
BiasY = v(8);
BiasZ = v(9);

for i = 1:n
    Xx = X(i,1);
    Xy = X(i,2);
    Xz = X(i,3);
    
    r = (ScaleMxx*(BiasX - Xx) + ScaleMxy*(BiasY - Xy) + ScaleMxz*(BiasZ - Xz))^2 + (ScaleMxy*(BiasX - Xx) + ScaleMyy*(BiasY - Xy) + ScaleMyz*(BiasZ - Xz))^2 + (ScaleMxz*(BiasX - Xx) + ScaleMyz*(BiasY - Xy) + ScaleMzz*(BiasZ - Xz))^2-1;
    Jacobian(i,1) = 2*(BiasX - Xx)*(ScaleMxx*(BiasX - Xx) + ScaleMxy*(BiasY - Xy) + ScaleMxz*(BiasZ - Xz));
    Jacobian(i,2) = 2*(BiasY - Xy)*(ScaleMxx*(BiasX - Xx) + ScaleMxy*(BiasY - Xy) + ScaleMxz*(BiasZ - Xz)) + 2*(BiasX - Xx)*(ScaleMxy*(BiasX - Xx) + ScaleMyy*(BiasY - Xy) + ScaleMyz*(BiasZ - Xz));
    Jacobian(i,3) = 2*(BiasX - Xx)*(ScaleMxz*(BiasX - Xx) + ScaleMyz*(BiasY - Xy) + ScaleMzz*(BiasZ - Xz)) + 2*(BiasZ - Xz)*(ScaleMxx*(BiasX - Xx) + ScaleMxy*(BiasY - Xy) + ScaleMxz*(BiasZ - Xz));
    Jacobian(i,4) = 2*(BiasY - Xy)*(ScaleMxy*(BiasX - Xx) + ScaleMyy*(BiasY - Xy) + ScaleMyz*(BiasZ - Xz));
    Jacobian(i,5) = 2*(BiasY - Xy)*(ScaleMxz*(BiasX - Xx) + ScaleMyz*(BiasY - Xy) + ScaleMzz*(BiasZ - Xz)) + 2*(BiasZ - Xz)*(ScaleMxy*(BiasX - Xx) + ScaleMyy*(BiasY - Xy) + ScaleMyz*(BiasZ - Xz));
    Jacobian(i,6) = 2*(BiasZ - Xz)*(ScaleMxz*(BiasX - Xx) + ScaleMyz*(BiasY - Xy) + ScaleMzz*(BiasZ - Xz));
    Jacobian(i,7) = 2*ScaleMxx*(ScaleMxx*(BiasX - Xx) + ScaleMxy*(BiasY - Xy) + ScaleMxz*(BiasZ - Xz)) + 2*ScaleMxy*(ScaleMxy*(BiasX - Xx) + ScaleMyy*(BiasY - Xy) + ScaleMyz*(BiasZ - Xz)) + 2*ScaleMxz*(ScaleMxz*(BiasX - Xx) + ScaleMyz*(BiasY - Xy) + ScaleMzz*(BiasZ - Xz));
    Jacobian(i,8) = 2*ScaleMxy*(ScaleMxx*(BiasX - Xx) + ScaleMxy*(BiasY - Xy) + ScaleMxz*(BiasZ - Xz)) + 2*ScaleMyy*(ScaleMxy*(BiasX - Xx) + ScaleMyy*(BiasY - Xy) + ScaleMyz*(BiasZ - Xz)) + 2*ScaleMyz*(ScaleMxz*(BiasX - Xx) + ScaleMyz*(BiasY - Xy) + ScaleMzz*(BiasZ - Xz));
    Jacobian(i,9) = 2*ScaleMxz*(ScaleMxx*(BiasX - Xx) + ScaleMxy*(BiasY - Xy) + ScaleMxz*(BiasZ - Xz)) + 2*ScaleMyz*(ScaleMxy*(BiasX - Xx) + ScaleMyy*(BiasY - Xy) + ScaleMyz*(BiasZ - Xz)) + 2*ScaleMzz*(ScaleMxz*(BiasX - Xx) + ScaleMyz*(BiasY - Xy) + ScaleMzz*(BiasZ - Xz));
    newR = newR + r*r;
    for j = 1:9
        D(j) = D(j) + Jacobian(i,j) *r;
    end
end
newR = sqrt(newR);
v = v - lambda*(transpose(D)/(Jacobian'*Jacobian));


% Adjust damping
if (newR <= lastR)
    lambda = lambda - k*lambda;
else
    lambda = k*lambda;
end
end

