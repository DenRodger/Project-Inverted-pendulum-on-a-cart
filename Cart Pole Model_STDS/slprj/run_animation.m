%% === М5. АНІМАЦІЯ СИСТЕМИ З КОЛЬОРОВОЮ ІНДИКАЦІЄЮ ===
close all;
clear all;

% 1. Завантажуємо параметри та запускаємо симуляцію
init_parameters; 
model_name = 'cart_pole_model';

fprintf('Запуск симуляції... ');
simData = sim(model_name);
fprintf('Дані успішно отримані!\n');

% 2. Витягуємо дані з Workspace
t = simData.tout;
x = simData.x_out;

% ОДО СЦЕЙ РЯДОК ВИПРАВИТЬ ВСЕ: переводимо отримані градуси в радіани для анімації
theta = deg2rad(simData.theta_out); 

if exist('l','var'), L = l; else L = 1.0; end

% 3. Налаштування графічного вікна
figure('Name', '2D Анімація: Візок та Маятник', 'Position', [200, 200, 900, 500]);
hold on; grid on;
axis equal;

% Визначаємо межі екрана на основі руху візка
xlim([min(x)-L*1.5, max(x)+L*1.5]);
ylim([-L*0.5, L*1.5]);
xlabel('Позиція візка, м');
ylabel('Висота, м');

% Малюємо рейку (колію)
plot([min(x)-5, max(x)+5], [0, 0], 'k-', 'LineWidth', 2);

% Ініціалізація графічних об'єктів (створюємо "заготовки")
% Візок (намалюємо як прямокутник)
cart_w = 0.4; cart_h = 0.2;
h_cart = rectangle('Position', [x(1)-cart_w/2, 0, cart_w, cart_h], 'FaceColor', [0.5 0.5 0.5], 'EdgeColor', 'k');

% Шарнір та маятник
h_rod = plot([x(1), x(1)], [cart_h, cart_h + L], 'k-', 'LineWidth', 3);
h_bob = plot(x(1), cart_h + L, 'o', 'MarkerSize', 12, 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k');

% Текстовий індикатор кута та зони стійкості
h_text = text(min(x)-L, L*1.3, '', 'FontSize', 12, 'FontWeight', 'bold');

% 4. Головний цикл анімації
% Скорочуємо крок (беремо кожну 5-ту або 10-ту точку), щоб анімація не гальмувала
step = max(1, round(length(t)/200)); 

for i = 1:step:length(t)
    % Поточні координати візка
    cx = x(i);
    cy = cart_h;
    
    % Поточні координати кінця маятника (θ=0 — це вертикально вгору)
    px = cx + L * sin(theta(i));
    py = cy + L * cos(theta(i));
    
    % Розрахунок кута в градусах для індикації
    angle_deg = abs(rad2deg(theta(i)));
    
    % --- КОЛЬОРОВА ІНДИКАЦІЯ ЗОНИ СТІЙКОСТІ ---
    if angle_deg < 5
        % ЗОНА 1: Повна стійкість (Зелений)
        current_color = [0, 0.8, 0]; 
        zone_text = sprintf('Стан: СТІЙКИЙ (Кут: %.2f°)', angle_deg);
    elseif angle_deg < 15
        % ЗОНА 2: Передкритичний стан / Відновлення (Жовтий/Помаранчевий)
        current_color = [1, 0.6, 0]; 
        zone_text = sprintf('Стан: УТРИМАННЯ (Кут: %.2f°)', angle_deg);
    else
        % ЗОНА 3: Нестійка зона / Падіння (Червоний)
        current_color = [0.9, 0, 0]; 
        zone_text = sprintf('Стан: КРИТИЧНИЙ/НЕСТІЙКИЙ (Кут: %.2f°)', angle_deg);
    end
    
    % Оновлюємо положення візка
    set(h_cart, 'Position', [cx-cart_w/2, 0, cart_w, cart_h]);
    
    % Оновлюємо стрижень маятника (колір змінюється динамічно)
    set(h_rod, 'XData', [cx, px], 'YData', [cy, py], 'Color', current_color);
    
    % Оновлюємо кульку (кулька дублює колір стійкості)
    set(h_bob, 'XData', px, 'YData', py, 'MarkerFaceColor', current_color);
    
    % Оновлюємо текст індикатора
    set(h_text, 'String', zone_text, 'Color', current_color);
    
    % Фокусуємо камеру, якщо візок зміщується далеко
    xlim([cx-L*2, cx+L*2]);
    
    % Омальовуємо кадр
    drawnow;
end

fprintf('Анімацію завершено!\n');