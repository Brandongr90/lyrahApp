//
//  OnboardingImprovementAreasView.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 25/04/25.
//

import SwiftUI

struct OnboardingImprovementAreasView: View {
    // Areas de mejora seleccionadas actualmente (desde el ViewModel)
    var selectedAreas: [ImprovementAreaSelection]
    // Funcion para actualizar las areas en el ViewModel
    var onUpdate: ([ImprovementAreaSelection]) -> Void
    
    // Estado local para trabajar con las selecciones
    @State private var localSelectedAreas: [ImprovementAreaSelection] = []
    @State private var availableAreas: [ImprovementAreaOption] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    // Opciones predefinidas según el Test 3.0
    private let predefinedAreas: [ImprovementAreaOption] = [
        ImprovementAreaOption(id: 1, name: "Dormir mejor y sentirme con más energía en el día", description: "Mejora del sueño y energía diaria"),
        ImprovementAreaOption(id: 2, name: "Aprender a gestionar mejor el estrés y las preocupaciones diarias", description: "Manejo del estrés y preocupaciones"),
        ImprovementAreaOption(id: 3, name: "Mantenerme motivado/a y enfocado/a en mis metas", description: "Motivación y enfoque en metas"),
        ImprovementAreaOption(id: 4, name: "Organizar mejor mi tiempo para equilibrar mis responsabilidades y mi bienestar", description: "Gestión del tiempo y equilibrio"),
        ImprovementAreaOption(id: 5, name: "Sentirme más seguro/a en mis decisiones y fortalecer mi crecimiento personal", description: "Seguridad en decisiones y crecimiento"),
        ImprovementAreaOption(id: 6, name: "Mejorar mi relación con el dinero y lograr mayor estabilidad financiera", description: "Relación con el dinero y estabilidad"),
        ImprovementAreaOption(id: 7, name: "Conectar mejor con los demás y fortalecer mis relaciones personales", description: "Conexión y relaciones personales"),
        ImprovementAreaOption(id: 8, name: "Tener más claridad en mi propósito y fortalecer mi conexión espiritual", description: "Propósito y conexión espiritual")
    ]
    
    init(selectedAreas: [ImprovementAreaSelection], onUpdate: @escaping ([ImprovementAreaSelection]) -> Void) {
        self.selectedAreas = selectedAreas
        self.onUpdate = onUpdate
        _localSelectedAreas = State(initialValue: selectedAreas)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("¿En qué aspectos de tu vida te gustaria mejorar?").font(.montserrat(fontStyle: .title3, fontWeight: .bold))
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 8)
            
            // Vista cuando hay areas seleccionadas
            if !localSelectedAreas.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tus áreas prioritarias")
                        .font(.montserrat(fontStyle: .headline, fontWeight: .medium))
                        .foregroundStyle(.primary)
                    
                    Text("Arrastra para reordenar según importancia")
                        .font(.montserrat(fontStyle: .caption))
                        .foregroundStyle(.secondary)
                    
                    // Lista de areas seleccionadas con posibilidad de reordenar
                    ForEach(Array(localSelectedAreas.enumerated()), id: \.element.id) { index, area in
                        SelectedAreaRow(
                            area: area,
                            index: index + 1,
                            onRemove: { removeArea(area) }
                        )
                        .padding(.vertical, 4)
                    }
                    .onMove(perform: moveArea)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05),radius: 5)
                )
            }
            
            // Lista de áreas disponibles para seleccionar
            VStack(alignment: .leading, spacing: 12) {
                Text("Áreas disponibles")
                    .font(.montserrat(fontStyle: .headline, fontWeight: .medium))
                    .foregroundColor(.primary)
                
                ForEach(availableAreasToShow, id: \.id) { area in
                    AvailableAreaRow(
                        area: area,
                        onSelect: { addArea(area) }
                    )
                    .padding(.vertical, 4)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 5)
            )
            
            Spacer()
        }
        .padding(.vertical, 16)
        .onAppear {
            loadAvailableAreas()
        }
    }
    
    // Áreas que aún no han sido seleccionadas
    private var availableAreasToShow: [ImprovementAreaOption] {
        availableAreas.filter { area in
            !localSelectedAreas.contains(where: { $0.id == area.id })
        }
    }
    
    // Cargar áreas desde API o usar predefinidas
    private func loadAvailableAreas() {
        isLoading = true
        
        // En un escenario real, aquí cargaríamos de la API
        // Por ahora usamos las predefinidas
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.availableAreas = self.predefinedAreas
            self.isLoading = false
        }
    }
    
    // Añadir un área a la selección
    private func addArea(_ area: ImprovementAreaOption) {
        // Creamos una nueva selección con el orden actual + 1
        let newSelection = ImprovementAreaSelection(
            optionId: area.id,
            name: area.name,
            description: area.description,
            priorityOrder: localSelectedAreas.count + 1
        )
        
        localSelectedAreas.append(newSelection)
        onUpdate(localSelectedAreas)
    }
    
    // Eliminar un área de la selección
    private func removeArea(_ area: ImprovementAreaSelection) {
        localSelectedAreas.removeAll(where: { $0.id == area.id })
        
        // Reordenar las áreas restantes
        for (index, _) in localSelectedAreas.enumerated() {
            localSelectedAreas[index].priorityOrder = index + 1
        }
        
        onUpdate(localSelectedAreas)
    }
    
    // Mover un área a una nueva posición
    private func moveArea(from source: IndexSet, to destination: Int) {
        localSelectedAreas.move(fromOffsets: source, toOffset: destination)
        
        // Actualizar los órdenes de prioridad
        for (index, _) in localSelectedAreas.enumerated() {
            localSelectedAreas[index].priorityOrder = index + 1
        }
        
        onUpdate(localSelectedAreas)
    }
}

// Componente para mostrar un área seleccionada
struct SelectedAreaRow: View {
    let area: ImprovementAreaSelection
    let index: Int
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            // Número de prioridad
            Text("\(index)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Color.adicionalOne))
            
            // Nombre del área
            Text(area.name)
                .font(.montserrat(fontStyle: .body))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Botón para eliminar
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

// Componente para mostrar un área disponible
struct AvailableAreaRow: View {
    let area: ImprovementAreaOption
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                Text(area.name)
                    .font(.montserrat(fontStyle: .body))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.adicionalOne)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.05))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    // Simulación de datos para el preview
    let mockSelections = [
        ImprovementAreaSelection(
            optionId: 1,
            name: "Dormir mejor y sentirme con más energía en el día",
            description: "Mejora del sueño y energía diaria",
            priorityOrder: 1
        ),
        ImprovementAreaSelection(
            optionId: 3,
            name: "Mantenerme motivado/a y enfocado/a en mis metas",
            description: "Motivación y enfoque en metas",
            priorityOrder: 2
        )
    ]
    
    return OnboardingImprovementAreasView(
        selectedAreas: mockSelections,
        onUpdate: { _ in } // Closure vacía para el mock
    )
}
