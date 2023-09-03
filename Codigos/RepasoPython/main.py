import plotly.graph_objects as go
import os
if not os.path.exists("images"):
    os.mkdir("images")


fig = go.Figure()

fig.add_trace(go.Scatter(
    x=[1, 2, 3, 4, 5],
    y=[1, 2, 3, 4, 5],
    mode='lines', 
    name="WMOS",
    line=dict(color="Green",width = 10),
))

fig.add_trace(go.Scatter(
    x=[1, 2, 3, 4, 5],
    y=[5, 4, 3, 2, 1],
    name="ASDA54"
))

fig.update_layout(legend_title_text='Termómetro',
                title = r'$\text{como andas }\beta_{x}$',
                title_x=0.5,
                width=800,  # Ancho en píxeles
                height=400, # Alto en píxeles
                xaxis=dict(
                    title="Tiempo $\\beta$",
                    range=[0, 10]),
                yaxis=dict(
                    title="Eje Y",
                    # position=0.5,
                    # tickvals=[0, 5, 10],
                    # ticktext=["Inicio", "Mitad", "Fin"]
                ),           
                plot_bgcolor='lightgray', # Color de fondo del área del gráfico
                paper_bgcolor='white',  # Color de fondo del papel (fondo del gráfico)
                
                title_font=dict(
                    color='blue'),  # Color del título
                
                legend_font=dict(
                    color='gray'),  # Color de la leyenda
                
                xaxis_title_font=dict(
                    color='red'),  # Color del título del eje X
                        
                legend=dict(
                    title="Termometro",
                    x=1,
                    y=1,
                    orientation="v"),
                margin=dict(
                    l=50,  # Márgen izquierdo
                    r=20,  # Márgen derecho
                    t=40,  # Márgen superior
                    b=40   # Márgen inferior
    )
                
                
                
                )  
   
fig.write_image("images/fig2.svg",format="svg")

# # Guardar la figura como PDF
# fig.write_image("Codigos\\RepasoPython\\image.pdf",format="pdf")



# # Guardar la figura como SVG
# fig.write_image("grafico.svg")


# import plotly.graph_objects as go
# import numpy as np
# np.random.seed(1)

# N = 100
# x = np.random.rand(N)
# y = np.random.rand(N)
# colors = np.random.rand(N)
# sz = np.random.rand(N) * 30

# fig = go.Figure()
# fig.add_trace(go.Scatter(
#     x=x,
#     y=y,
#     mode="markers",
#     marker=go.scatter.Marker(
#         size=sz,
#         color=colors,
#         opacity=0.6,
#         colorscale="Viridis"
#     )
# ))

# fig.show()

# import os

# if not os.path.exists("images"):
#     os.mkdir("images")
    
# fig.write_image("images/fig1.png")