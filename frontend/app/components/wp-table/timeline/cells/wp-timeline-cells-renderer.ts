// -- copyright
// OpenProject is a project management system.
// Copyright (C) 2012-2015 the OpenProject Foundation (OPF)
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License version 3.
//
// OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
// Copyright (C) 2006-2013 Jean-Philippe Lang
// Copyright (C) 2010-2013 the ChiliProject Team
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
// See doc/COPYRIGHT.rdoc for more details.
// ++
import {States} from '../../../states.service';
import {RenderInfo} from '../wp-timeline';
import {TimelineMilestoneCellRenderer} from './timeline-milestone-cell-renderer';
import {TimelineCellRenderer} from './timeline-cell-renderer';
import {WorkPackageTimelineTableController} from '../container/wp-timeline-container.directive';
import {$injectFields} from '../../../angular/angular-injector-bridge.functions';
import {WorkPackageTimelineCell} from './wp-timeline-cell';
import {RenderedRow} from '../../../wp-fast-table/builders/primary-render-pass';
import {WorkPackageChangeset} from '../../../wp-edit-form/work-package-changeset';

export class WorkPackageTimelineCellsRenderer {
  // Injections
  public states:States;

  public cells:{ [classIdentifier:string]:WorkPackageTimelineCell } = {};

  private cellRenderers:{ milestone:TimelineMilestoneCellRenderer, generic:TimelineCellRenderer };

  constructor(private wpTimeline:WorkPackageTimelineTableController) {
    $injectFields(this, 'states');

    this.cellRenderers = {
      milestone: new TimelineMilestoneCellRenderer(wpTimeline),
      generic: new TimelineCellRenderer(wpTimeline)
    };
  }

  public hasCell(wpId:string) {
    return this.getCellsFor(wpId).length > 0;
  }

  public getCellsFor(wpId:string):WorkPackageTimelineCell[] {
    return _.filter(this.cells, (cell) => cell.workPackageId === wpId) || [];
  }

  /**
   * Synchronize the currently active cells and render them all
   */
  public refreshAllCells() {
    // Create new cells and delete old ones
    this.synchronizeCells();

    // Update all cells
    _.each(this.cells, (cell) => this.refreshSingleCell(cell));
  }

  public refreshCellsFor(wpId:string) {
    _.each(this.getCellsFor(wpId), (cell) => this.refreshSingleCell(cell));
  }

  public refreshSingleCell(cell:WorkPackageTimelineCell) {
    const renderInfo = this.renderInfoFor(cell.workPackageId);

    if (renderInfo.workPackage) {
      cell.refreshView(renderInfo);
    }
  }

  /**
   * Synchronize the current cells:
   *
   * 1. Create new cells in workPackageIdOrder not yet tracked
   * 2. Remove old cells no longer contained.
   */
  private synchronizeCells() {
    const currentlyActive:string[] = Object.keys(this.cells);
    const newCells:string[] = [];

    _.each(this.wpTimeline.workPackageIdOrder, (renderedRow:RenderedRow) => {
      const wpId = renderedRow.workPackageId;

      // Ignore extra rows not tied to a work package
      if (!wpId) {
        return;
      }

      const state = this.states.workPackages.get(wpId);
      if (state.isPristine()) {
        return;
      }

      // As work packages may occur several times, get the unique identifier
      // to identify the cell
      const identifier = renderedRow.classIdentifier;

      // Create a cell unless we already have an active cell
      if (!this.cells[identifier]) {
        this.cells[identifier] = this.buildCell(identifier, wpId.toString());
      }

      newCells.push(identifier);
    });

    _.difference(currentlyActive, newCells).forEach((identifier:string) => {
      this.cells[identifier].clear();
      delete this.cells[identifier];
    });
  }

  private buildCell(classIdentifier:string, workPackageId:string) {
    return new WorkPackageTimelineCell(
      this.wpTimeline,
      this.cellRenderers,
      this.renderInfoFor(workPackageId),
      classIdentifier,
      workPackageId
    );
  }

  private renderInfoFor(wpId:string):RenderInfo {
    const wp = this.states.workPackages.get(wpId).value!;
    return {
      viewParams: this.wpTimeline.viewParameters,
      workPackage: wp,
      changeset: new WorkPackageChangeset(wp)
    } as RenderInfo;
  }
}
