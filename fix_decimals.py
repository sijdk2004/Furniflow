import glob

replacements = {
    "subtitle: '+${kpis['revenue_growth'] ?? 0}%'": "subtitle: '+${(kpis['revenue_growth'] as num? ?? 0).toStringAsFixed(2)}%'",
    "subtitle: '+${kpis['active_orders_growth'] ?? 0}%'": "subtitle: '+${(kpis['active_orders_growth'] as num? ?? 0).toStringAsFixed(2)}%'",
    "subtitle: '+${kpis['quotations_growth'] ?? 0}%'": "subtitle: '+${(kpis['quotations_growth'] as num? ?? 0).toStringAsFixed(2)}%'",
    "subtitle: '+${kpis['customers_growth'] ?? 0}%'": "subtitle: '+${(kpis['customers_growth'] as num? ?? 0).toStringAsFixed(2)}%'",
    "subtitle: '+${kpis['sales_orders_growth'] ?? 0}%'": "subtitle: '+${(kpis['sales_orders_growth'] as num? ?? 0).toStringAsFixed(2)}%'",
    "${kpis['quotation_conversion_rate']?.toStringAsFixed(1) ?? 0}% Rate": "${kpis['quotation_conversion_rate']?.toStringAsFixed(2) ?? '0.00'}% Rate",
    "${(kpis['production_efficiency_percentage'] ?? 0).toStringAsFixed(1)}%": "${(kpis['production_efficiency_percentage'] ?? 0).toStringAsFixed(2)}%",
    "${(kpis['delivery_success_rate'] ?? 0).toStringAsFixed(1)}%": "${(kpis['delivery_success_rate'] ?? 0).toStringAsFixed(2)}%"
}

path = r'd:\Jayaraman Docs\Stellar\ERP_Platform\ERP Platform\Furniture Pack\Furniflow_codebase\Furniflow\lib\features\dashboard\presentation\**\*.dart'

for file_path in glob.glob(path, recursive=True):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    new_content = content
    for old, new in replacements.items():
        new_content = new_content.replace(old, new)
        
    if new_content != content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f'Updated {file_path}')
